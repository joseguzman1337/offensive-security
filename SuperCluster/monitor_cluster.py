# monitor_cluster.py
import ipaddress
import re
import shlex
import socket
import subprocess
from datetime import datetime

from flask import Flask, jsonify, render_template

# psutil is imported lazily inside the function that uses it. This lets
# the fuzz harness import the validation primitive `_validate_scan_target`
# without pulling in the psutil runtime stack (which is a C extension and
# can fail in minimal CI/fuzz environments).
# Refactored 2026-07-10 to enable fuzzing (closes Scorecard FuzzingID).

app = Flask(__name__)


@app.after_request
def add_security_headers(response):
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "SAMEORIGIN"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Content-Security-Policy"] = "default-src 'self'"
    return response


def _validate_scan_target(target):
    """Validate that target is a valid IP address, CIDR range, or hostname."""
    # Try parsing as IP address or network
    try:
        ipaddress.ip_address(target)
        return True
    except ValueError:
        pass
    try:
        ipaddress.ip_network(target, strict=False)
        return True
    except ValueError:
        pass
    # Validate as hostname (RFC 1123)
    if re.fullmatch(
        r"(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9](?:[a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?",
        target,
    ):
        return True
    return False


class ClusterMonitor:
    def __init__(self, hostfile: str = "hostfile"):
        # nodes loaded lazily so the module is importable in test/fuzz
        # contexts where the hostfile isn't present.
        self._hostfile = hostfile
        self.nodes: list[str] | None = None

    def _ensure_nodes(self) -> list[str]:
        if self.nodes is None:
            self.nodes = self.load_hostfile()
        return self.nodes

    def load_hostfile(self):
        try:
            with open(self._hostfile, "r") as f:
                return [
                    parts[0]
                    for line in f
                    if (parts := line.strip().split()) and not parts[0].startswith("#")
                ]
        except FileNotFoundError:
            return []  # no hostfile yet — running outside cluster context

    def get_node_status(self, node_ip):
        """Check if node is responsive"""
        try:
            socket.create_connection((node_ip, 22), timeout=2)
            return "online"
        except (OSError, socket.error, socket.timeout):
            return "offline"

    def get_cluster_metrics(self):
        # Lazy import: psutil is only needed for runtime metrics, not for
        # the validation primitive or fuzz harness.
        import psutil  # type: ignore  # noqa: WPS433,PLC0415

        nodes = self._ensure_nodes()
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "total_nodes": len(nodes),
            "online_nodes": 0,
            "cpu_usage": psutil.cpu_percent(),
            "memory_usage": psutil.virtual_memory().percent,
            "nodes": [],
        }

        for node in nodes:
            status = self.get_node_status(node)
            if status == "online":
                metrics["online_nodes"] += 1
            metrics["nodes"].append(
                {"ip": node, "status": status, "last_check": datetime.now().isoformat()}
            )

        return metrics


monitor = ClusterMonitor()


@app.route("/")
def dashboard():
    return render_template("dashboard.html")


@app.route("/api/metrics")
def get_metrics():
    return jsonify(monitor.get_cluster_metrics())


@app.route("/api/run_scan/<target>")
def run_scan(target):
    if not _validate_scan_target(target):
        return jsonify({"error": "Invalid scan target"}), 400
    nodes = monitor._ensure_nodes()
    result = subprocess.run(
        [
            "mpirun",
            "--hostfile",
            "hostfile",
            "-np",
            str(len(nodes)),
            "python",
            "security_scanner.py",
            shlex.quote(target),
        ],
        capture_output=True,
        text=True,
        check=True,
        timeout=30,
    )
    return jsonify({"output": result.stdout})
