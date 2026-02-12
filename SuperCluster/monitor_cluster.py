# monitor_cluster.py
import ipaddress
import re
import shlex
import socket
import subprocess
from datetime import datetime

import psutil
from flask import Flask, jsonify, render_template

app = Flask(__name__)


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
        r"[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*",
        target,
    ):
        return True
    return False


class ClusterMonitor:
    def __init__(self):
        self.nodes = self.load_hostfile()

    def load_hostfile(self):
        with open("hostfile", "r") as f:
            return [line.split()[0] for line in f if not line.startswith("#")]

    def get_node_status(self, node_ip):
        """Check if node is responsive"""
        try:
            socket.create_connection((node_ip, 22), timeout=2)
            return "online"
        except (OSError, socket.error, socket.timeout):
            return "offline"

    def get_cluster_metrics(self):
        metrics = {
            "timestamp": datetime.now().isoformat(),
            "total_nodes": len(self.nodes),
            "online_nodes": 0,
            "cpu_usage": psutil.cpu_percent(),
            "memory_usage": psutil.virtual_memory().percent,
            "nodes": [],
        }

        for node in self.nodes:
            status = self.get_node_status(node)
            if status == "online":
                metrics["online_nodes"] += 1
            metrics["nodes"].append(
                {"ip": node, "status": status,
                    "last_check": datetime.now().isoformat()}
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
    result = subprocess.run(
        [
            "mpirun",
            "--hostfile",
            "hostfile",
            "-np",
            str(len(monitor.nodes)),
            "python",
            "security_scanner.py",
            shlex.quote(target),
        ],
        capture_output=True,
        text=True,
    )
    return jsonify({"output": result.stdout})
