#!/usr/bin/env python3
"""
BlackArch All-In-One (AIO) Manager
Migrated and consolidated from multiple scripts.
"""

import argparse
import asyncio
import configparser
import json
import logging
import os
import platform
import shutil
import subprocess
import sys
import time
import typing
from concurrent.futures import ThreadPoolExecutor
from contextlib import asynccontextmanager, contextmanager
from datetime import datetime

# --- Dependencies Check & Auto-Install ---
REQUIRED_PACKAGES = [
    "requests",
    "tqdm",
    "colorama",
]


def install_missing_dependencies():
    """Installs missing Python dependencies using pacman."""
    missing = []
    for pkg in REQUIRED_PACKAGES:
        try:
            __import__(pkg)
        except ImportError:
            missing.append(pkg)

    if missing:
        print(f"Installing missing dependencies: {', '.join(missing)}")
        pkg_map = {
            "requests": "python-requests",
            "tqdm": "python-tqdm",
            "colorama": "python-colorama",
        }
        for lib in missing:
            pkg_name = pkg_map.get(lib, f"python-{lib}")
            subprocess.run(
                ["sudo", "pacman", "-S", "--needed", "--noconfirm", pkg_name],
                check=False,
            )


install_missing_dependencies()

try:
    import requests
    from colorama import Fore, Style
    from tqdm import tqdm
except ImportError as e:
    print(
        f"Critical: Failed to import dependencies even after install attempt: {e}")

# --- Constants & Configuration ---
PACMAN_CONF = "/etc/pacman.conf"
LOG_FILE = "blackarch_aio.log"
MIRRORS_URL = "https://github.com/BlackArch/blackarch/blob/master/mirror/mirror.lst"
MIRRORLIST_FILE = "/etc/pacman.d/blackarch-mirrorlist"

AUR_HELPERS = {
    "yay": {
        "install": ["yay", "-S", "--needed", "--noconfirm"],
        "upgrade": [
            "yay",
            "-Syuu",
            "--noconfirm",
            "--answerclean=All",
            "--answerdiff=None",
            "--mflags",
            "'--nocheck'",
            "--overwrite",
            "'*'",
        ],
        "download": ["yay", "-Syuuw", "--noconfirm"],
    },
    "paru": {
        "install": ["paru", "-S", "--needed", "--noconfirm"],
        "upgrade": [
            "paru",
            "-Syuu",
            "--noconfirm",
            "--mflags",
            "'--nocheck'",
            "--overwrite",
            "'*'",
        ],
        "download": ["paru", "-Syuuw", "--noconfirm"],
    },
    "pacaur": {
        "install": ["pacaur", "-S", "--needed", "--noconfirm"],
        "upgrade": ["pacaur", "-Syuu", "--noconfirm", "--noedit"],
        "download": ["pacaur", "-Syuuw", "--noconfirm"],
    },
    "trizen": {
        "install": ["trizen", "-S", "--needed", "--noconfirm", "--noedit"],
        "upgrade": ["trizen", "-Syuu", "--noconfirm", "--noedit"],
        "download": ["trizen", "-Syuuw", "--noconfirm", "--noedit"],
    },
    "pikaur": {
        "install": ["pikaur", "-S", "--needed", "--noconfirm"],
        "upgrade": ["pikaur", "-Syuu", "--noconfirm"],
        "download": ["pikaur", "-Syuuw", "--noconfirm"],
    },
    "aurman": {
        "install": ["aurman", "-S", "--needed", "--noconfirm", "--noedit"],
        "upgrade": ["aurman", "-Syuu", "--noconfirm", "--noedit"],
        "download": ["aurman", "-Syuuw", "--noconfirm", "--noedit"],
    },
    "pamac": {
        "install": ["pamac", "install", "--no-confirm"],
        "upgrade": ["pamac", "upgrade", "--no-confirm"],
        "download": ["pamac", "update", "--download-only-no-confirm"],
    },
    "pacman": {
        "install": [
            "sudo",
            "pacman",
            "-S",
            "--needed",
            "--noconfirm",
            "--disable-download-timeout",
        ],
        "upgrade": [
            "sudo",
            "pacman",
            "-Syuu",
            "--needed",
            "--noconfirm",
            "--noprogressbar",
            "--disable-download-timeout",
            "--ask",
            "4",
            "--overwrite",
            "'*'",
        ],
        "download": [
            "sudo",
            "pacman",
            "-Syuuw",
            "--needed",
            "--noconfirm",
            "--noprogressbar",
            "--disable-download-timeout",
            "--ask",
            "4",
        ],
    },
    # GUI-only helpers (excluded from automated logic)
    "bauh": {"gui": True},
    "octopi": {"gui": True},
}

PACKAGES_TO_INSTALL = ["blackarch", "blackarch-officials"]

CATEGORIES = [
    "blackarch-anti-forensic",
    "blackarch-automation",
    "blackarch-backdoor",
    "blackarch-binary",
    "blackarch-bluetooth",
    "blackarch-code-audit",
    "blackarch-config",
    "blackarch-cracker",
    "blackarch-crypto",
    "blackarch-database",
    "blackarch-debugger",
    "blackarch-decompiler",
    "blackarch-disassembler",
    "blackarch-dos",
    "blackarch-drone",
    "blackarch-exploitation",
    "blackarch-forensic",
    "blackarch-fingerprint",
    "blackarch-firmware",
    "blackarch-fuzzer",
    "blackarch-gpu",
    "blackarch-hardware",
    "blackarch-honeypot",
    "blackarch-ids",
    "blackarch-keylogger",
    "blackarch-malware",
    "blackarch-misc",
    "blackarch-mobile",
    "blackarch-networking",
    "blackarch-nfc",
    "blackarch-packer",
    "blackarch-proxy",
    "blackarch-radio",
    "blackarch-recon",
    "blackarch-reversing",
    "blackarch-scanner",
    "blackarch-sniffer",
    "blackarch-social",
    "blackarch-spoof",
    "blackarch-stego",
    "blackarch-tunnel",
    "blackarch-unpacker",
    "blackarch-voip",
    "blackarch-webap",
    "blackarch-webapp",
    "blackarch-windows",
    "blackarch-wireless",
]

# --- Logging Setup ---
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logging.getLogger("").addHandler(console)


# --- Utils Module ---
class Utils:
    @staticmethod
    def run_command(
        command: list[str], suppress_output: bool = False, retries: int = 3
    ) -> typing.Optional[str]:
        for attempt in range(retries):
            try:
                result = subprocess.run(
                    command,
                    check=True,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT if suppress_output else subprocess.PIPE,
                    encoding="utf-8",
                )
                return result.stdout
            except subprocess.CalledProcessError as e:
                logging.warning(
                    f"Command '{' '.join(command)}' failed (attempt {attempt + 1}/{retries}):"
                )
                logging.warning(f"Error output:\n{e.stdout}")
                if attempt < retries - 1:
                    time.sleep(5)
                else:
                    raise

    @staticmethod
    def is_helper_installed(helper: str) -> bool:
        if helper == "pacman":
            return True
        return shutil.which(helper) is not None


# --- Repos & Mirrorlist Module ---
class Repos:
    @staticmethod
    def fetch_mirrors():
        # Using the raw content URL directly to avoid git clone/auth issues
        MIRRORS_RAW_URL = "https://raw.githubusercontent.com/BlackArch/blackarch/master/mirror/mirror.lst"
        try:
            response = requests.get(MIRRORS_RAW_URL)
            response.raise_for_status()
            mirrors = []
            for line in response.text.splitlines():
                if line.startswith("Server = "):
                    mirrors.append(line.split("#")[0].strip()[8:])
            return mirrors
        except Exception as e:
            logging.error(f"Failed to fetch mirrors: {e}")
            return []

    # Nearby country groups for proximity-based mirror expansion.
    # When a country has few mirrors, we pull from geographic neighbors.
    NEARBY_COUNTRIES = {
        # Latin America
        "CO": ["CO", "EC", "VE", "PA", "BR", "CL", "US"],
        "EC": ["EC", "CO", "PE", "CL", "BR", "US"],
        "BR": ["BR", "CL", "CO", "AR", "US"],
        "CL": ["CL", "BR", "AR", "CO", "US"],
        "AR": ["AR", "CL", "BR", "UY", "US"],
        "MX": ["MX", "US", "CA", "CO", "BR"],
        # North America
        "US": ["US", "CA"],
        "CA": ["CA", "US"],
        # Europe West
        "DE": ["DE", "AT", "NL", "CZ", "FR", "DK"],
        "FR": ["FR", "DE", "BE", "NL", "GB", "ES"],
        "GB": ["GB", "IE", "FR", "NL", "DE"],
        "NL": ["NL", "DE", "BE", "FR", "GB"],
        "ES": ["ES", "FR", "PT", "IT"],
        "IT": ["IT", "AT", "DE", "FR", "CH"],
        "AT": ["AT", "DE", "CZ", "HU", "IT"],
        "CH": ["CH", "DE", "FR", "AT", "IT"],
        "BE": ["BE", "NL", "DE", "FR", "GB"],
        # Europe North
        "SE": ["SE", "NO", "DK", "FI", "DE"],
        "NO": ["NO", "SE", "DK", "FI", "DE"],
        "DK": ["DK", "SE", "NO", "DE", "NL"],
        "FI": ["FI", "SE", "EE", "NO", "DE"],
        # Europe East
        "PL": ["PL", "CZ", "DE", "SK", "AT"],
        "CZ": ["CZ", "DE", "PL", "AT", "SK"],
        "RO": ["RO", "BG", "HU", "PL", "DE"],
        "HU": ["HU", "AT", "SK", "CZ", "RO"],
        # Asia
        "JP": ["JP", "KR", "TW", "HK", "SG"],
        "KR": ["KR", "JP", "TW", "HK", "SG"],
        "IN": ["IN", "SG", "BD", "HK", "JP"],
        "SG": ["SG", "HK", "JP", "IN", "AU"],
        "CN": ["CN", "HK", "TW", "JP", "KR", "SG"],
        "AU": ["AU", "NZ", "SG", "JP", "US"],
        "NZ": ["NZ", "AU", "SG", "JP"],
    }

    @staticmethod
    def get_location_info() -> dict:
        """Get geolocation via ipinfo.io (no extra dependencies)."""
        try:
            logging.info("Requested http://ipinfo.io/json")
            resp = requests.get("http://ipinfo.io/json", timeout=5)
            resp.raise_for_status()
            return resp.json()
        except Exception as e:
            logging.warning(f"Geolocation lookup failed: {e}")
            return {}

    @staticmethod
    def _ensure_reflector():
        """Install reflector if missing."""
        if not Utils.is_helper_installed("reflector"):
            Utils.run_command(
                ["sudo", "pacman", "-S", "--needed", "--noconfirm", "reflector"]
            )

    @staticmethod
    def _run_reflector(args: list[str], label: str) -> bool:
        """Run reflector with given args, return True on success."""
        cmd = ["sudo", "reflector"] + args
        logging.info(f"Running: {' '.join(cmd)}")
        try:
            subprocess.run(cmd, check=True, timeout=120,
                           stderr=subprocess.DEVNULL)
            return True
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
            logging.warning(f"Reflector {label} failed: {e}")
            return False

    @staticmethod
    def update_mirrorlist(country: str = None):
        """Optimizes mirrorlist using geolocation, proximity, health checks, and speed testing.

        Strategy (cascading fallback):
          1. Country + nearby neighbors, age < 1h, completion 100%, fastest 15, sorted by rate
          2. Country-only with relaxed age (12h)
          3. Global fastest 20 with health thresholds
        """
        Repos._ensure_reflector()

        geo = {}
        if not country:
            geo = Repos.get_location_info()
            country = geo.get("country")

        logging.info(
            f"Optimizing mirrors for location: {country or 'Global'} "
            f"({geo.get('city', '?')}, {geo.get('region', '?')})"
        )

        base_args = [
            "--protocol",
            "https",
            "--completion-percent",
            "100",
            "--connection-timeout",
            "3",
            "--download-timeout",
            "5",
            "--threads",
            "4",
            "--save",
            "/etc/pacman.d/mirrorlist",
        ]

        # --- Tier 1: Proximity with neighbors, strict freshness ---
        if country:
            neighbors = Repos.NEARBY_COUNTRIES.get(country, [country])
            country_csv = ",".join(neighbors)
            tier1_args = [
                "--country",
                country_csv,
                "--age",
                "1",
                "--delay",
                "0.5",
                "--fastest",
                "15",
                "--sort",
                "rate",
            ] + base_args
            logging.info(
                f"Tier 1: proximity ({country_csv}), age<1h, delay<30min")
            if Repos._run_reflector(tier1_args, "tier1-proximity"):
                logging.info("Mirrorlist optimized via proximity + freshness.")
                return

        # --- Tier 2: Country-only, relaxed age ---
        if country:
            tier2_args = [
                "--country",
                country,
                "--age",
                "12",
                "--score",
                "10",
                "--fastest",
                "10",
                "--sort",
                "rate",
            ] + base_args
            logging.info(f"Tier 2: country-only ({country}), age<12h")
            if Repos._run_reflector(tier2_args, "tier2-country"):
                logging.info("Mirrorlist optimized via country fallback.")
                return

        # --- Tier 3: Global fastest with health thresholds ---
        tier3_args = [
            "--age",
            "12",
            "--score",
            "15",
            "--completion-percent",
            "95",
            "--fastest",
            "20",
            "--sort",
            "rate",
            "--protocol",
            "https",
            "--connection-timeout",
            "3",
            "--download-timeout",
            "5",
            "--threads",
            "4",
            "--save",
            "/etc/pacman.d/mirrorlist",
        ]
        logging.info("Tier 3: global fastest with health thresholds")
        if Repos._run_reflector(tier3_args, "tier3-global"):
            logging.info("Mirrorlist optimized via global fastest.")
            return

        logging.error("All reflector tiers failed. Mirrorlist unchanged.")


# --- Helper Management Module ---
class HelperManager:
    @staticmethod
    def install_helper_if_missing(helper: str, command: list[str]):
        if not Utils.is_helper_installed(helper):
            logging.info(f"AUR helper '{helper}' not found. Installing...")
            try:
                Utils.run_command(command)
                logging.info(f"Successfully installed '{helper}'.")
            except Exception as e:
                logging.error(f"Failed to install '{helper}': {e}")

    @staticmethod
    def ensure_helpers():
        # Install yay first using pacman as the primary gateway
        HelperManager.install_helper_if_missing(
            "yay", ["sudo", "pacman", "-S", "--needed", "--noconfirm", "yay"]
        )
        # Install others via the best available helper
        all_helpers = ["paru", "pacaur", "trizen", "pikaur", "aurman", "pamac"]
        for helper in all_helpers:
            if not Utils.is_helper_installed(helper):
                logging.info(f"Attempting to install {helper}...")
                HelperManager.install_helper_if_missing(
                    helper, ["yay", "-S", "--needed", "--noconfirm", helper]
                )


# --- Package Management Module ---
class PackageManager:
    @staticmethod
    def get_best_helper():
        """Returns the first installed helper from prioritized list."""
        for helper in ["paru", "yay", "trizen", "pikaur", "pacaur", "pamac"]:
            if Utils.is_helper_installed(helper):
                return helper
        return "pacman"

    @staticmethod
    @staticmethod
    def smart_upgrade_package(pkg):
        """Attempts to upgrade a package using available helpers sequentially."""
        helpers_to_try = [
            "pacman",
            "paru",
            "yay",
            "trizen",
            "pikaur",
            "pacaur",
            "pamac",
            "aurman",
        ]
        for h_name in helpers_to_try:
            if not Utils.is_helper_installed(h_name):
                continue

            h_config = AUR_HELPERS.get(h_name)
            if not h_config:
                continue

            cmd = h_config["install"] + [pkg]
            try:
                subprocess.check_call(
                    cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
                return True, h_name
            except subprocess.CalledProcessError:
                continue
        return False, None

    @staticmethod
    def fix_problematic_packages():
        config = configparser.ConfigParser()
        config.read(PACMAN_CONF)
        problematic = []
        for package in PACKAGES_TO_INSTALL:
            success, _ = PackageManager.smart_upgrade_package(package)
            if not success:
                logging.warning(f"All helpers failed for package: {package}")
                problematic.append(package)
        if problematic:
            logging.info(
                f"Adding problematic packages to IgnorePkg: {problematic}")
            if "options" not in config:
                config["options"] = {}
            existing_ignore = config["options"].get("IgnorePkg", "")
            new_ignore = " ".join(set(existing_ignore.split() + problematic))
            config["options"]["IgnorePkg"] = new_ignore
            try:
                with open(PACMAN_CONF, "w") as f:
                    config.write(f)
            except Exception as e:
                logging.error(f"Failed to update {PACMAN_CONF}: {e}")

    @staticmethod
    def upgrade_all_packages_synced():
        """Synchronous update logic with multi-helper fallback."""
        try:
            pacman_list = subprocess.Popen(
                ["pacman", "-Qqe"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
            )
            out, _ = pacman_list.communicate()
            if pacman_list.returncode == 0:
                pkgs = [
                    line.strip() for line in out.decode("utf-8").split("\n") if line
                ]
                progress = tqdm(pkgs, desc="Upgrading packages", unit="pkg")
                success_count, fail_count = 0, 0
                for pkg in progress:
                    success, _ = PackageManager.smart_upgrade_package(pkg)
                    if success:
                        success_count += 1
                        progress.set_postfix({"Status": "Success"})
                    else:
                        fail_count += 1
                        progress.set_postfix({"Status": "Fail"})
                print(
                    f"Upgrade Complete. Success: {success_count}, Fail: {fail_count}")
        except Exception as e:
            logging.error(f"Upgrade failed: {e}")


# --- Kernel Upgrade Manager Module ---
class KernelManager:
    """Handles kernel upgrades with snapper snapshots, DKMS rebuilds, and dracut/kernel-install fixes."""

    DRACUT_CONF = "/etc/dracut.conf.d/99-fix-boot.conf"
    KERNEL_INSTALL_CONF = "/etc/kernel/install.conf"

    @staticmethod
    def is_snapper_available() -> bool:
        try:
            subprocess.run(
                ["snapper", "--version"],
                check=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return True
        except (FileNotFoundError, subprocess.CalledProcessError):
            return False

    @staticmethod
    def snapper_create(
        description: str, snapshot_type: str = "single", cleanup: str = "number"
    ) -> typing.Optional[int]:
        """Creates a snapper snapshot and returns the snapshot number."""
        if not KernelManager.is_snapper_available():
            logging.warning("snapper not available — skipping snapshot")
            return None
        try:
            result = subprocess.run(
                [
                    "sudo",
                    "snapper",
                    "create",
                    "--type",
                    snapshot_type,
                    "--cleanup-algorithm",
                    cleanup,
                    "--description",
                    description,
                    "--print-number",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            snap_num = int(result.stdout.strip())
            logging.info(
                f"Snapper snapshot #{snap_num} created: {description}")
            return snap_num
        except Exception as e:
            logging.error(f"Failed to create snapper snapshot: {e}")
            return None

    @staticmethod
    def snapper_create_pre(description: str) -> typing.Optional[int]:
        """Creates a snapper pre-snapshot for a pre/post pair."""
        if not KernelManager.is_snapper_available():
            logging.warning("snapper not available — skipping pre-snapshot")
            return None
        try:
            result = subprocess.run(
                [
                    "sudo",
                    "snapper",
                    "create",
                    "--type",
                    "pre",
                    "--cleanup-algorithm",
                    "number",
                    "--description",
                    description,
                    "--print-number",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            snap_num = int(result.stdout.strip())
            logging.info(
                f"Snapper PRE-snapshot #{snap_num} created: {description}")
            return snap_num
        except Exception as e:
            logging.error(f"Failed to create snapper pre-snapshot: {e}")
            return None

    @staticmethod
    def snapper_create_post(pre_number: int, description: str) -> typing.Optional[int]:
        """Creates a snapper post-snapshot paired with a pre-snapshot."""
        if not KernelManager.is_snapper_available() or pre_number is None:
            logging.warning(
                "snapper not available or no pre-snapshot — skipping post-snapshot"
            )
            return None
        try:
            result = subprocess.run(
                [
                    "sudo",
                    "snapper",
                    "create",
                    "--type",
                    "post",
                    "--pre-number",
                    str(pre_number),
                    "--cleanup-algorithm",
                    "number",
                    "--description",
                    description,
                    "--print-number",
                ],
                check=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            snap_num = int(result.stdout.strip())
            logging.info(
                f"Snapper POST-snapshot #{snap_num} (paired with pre #{pre_number}): {description}"
            )
            return snap_num
        except Exception as e:
            logging.error(f"Failed to create snapper post-snapshot: {e}")
            return None

    @staticmethod
    @contextmanager
    def snap_wrap(description: str):
        """Synchronous context manager: creates snapper pre/post around any block."""
        pre = KernelManager.snapper_create_pre(f"{description} [pre]")
        status = "OK"
        try:
            yield pre
        except Exception:
            status = "FAILED"
            raise
        finally:
            KernelManager.snapper_create_post(
                pre, f"{description} [post-{status}]")

    @staticmethod
    @asynccontextmanager
    async def async_snap_wrap(description: str):
        """Async context manager: creates snapper pre/post around any async block."""
        pre = await asyncio.to_thread(
            KernelManager.snapper_create_pre, f"{description} [pre]"
        )
        status = "OK"
        try:
            yield pre
        except Exception:
            status = "FAILED"
            raise
        finally:
            await asyncio.to_thread(
                KernelManager.snapper_create_post, pre, f"{description} [post-{status}]"
            )

    @staticmethod
    def detect_kernel_update_pending() -> typing.Tuple[bool, list[str]]:
        """Checks if a kernel package is among pending upgrades."""
        kernel_patterns = ["linux", "linux-zen", "linux-lts", "linux-hardened"]
        try:
            result = subprocess.run(
                ["pacman", "-Qu"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            if result.returncode != 0:
                return False, []
            pending = result.stdout.strip().splitlines()
            kernel_pkgs = []
            for line in pending:
                pkg_name = line.split()[0] if line.strip() else ""
                if (
                    pkg_name in kernel_patterns
                    or pkg_name.startswith("linux-zen")
                    or pkg_name.startswith("linux-lts")
                    or pkg_name.startswith("linux-hardened")
                ):
                    kernel_pkgs.append(line.strip())
            return len(kernel_pkgs) > 0, kernel_pkgs
        except Exception as e:
            logging.error(f"Failed to check pending kernel updates: {e}")
            return False, []

    @staticmethod
    def get_running_kernel() -> str:
        """Returns the currently running kernel version string."""
        try:
            return platform.release()
        except Exception:
            return "unknown"

    @staticmethod
    def get_installed_dkms_modules() -> list[dict]:
        """Returns a list of DKMS modules and their status."""
        modules = []
        try:
            result = subprocess.run(
                ["dkms", "status"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            if result.returncode != 0:
                logging.info("DKMS not installed or no modules registered.")
                return []
            for line in result.stdout.strip().splitlines():
                if line.strip():
                    modules.append({"raw": line.strip()})
            return modules
        except FileNotFoundError:
            logging.info("DKMS is not installed on this system.")
            return []
        except Exception as e:
            logging.error(f"Failed to query DKMS status: {e}")
            return []

    @staticmethod
    def rebuild_dkms_all() -> bool:
        """Rebuilds all DKMS modules for the currently installed kernels."""
        logging.info("Rebuilding all DKMS modules...")
        try:
            result = subprocess.run(
                ["sudo", "dkms", "autoinstall"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            if result.returncode == 0:
                logging.info("DKMS autoinstall completed successfully.")
                logging.info(f"DKMS output: {result.stdout.strip()}")
                return True
            else:
                logging.error(
                    f"DKMS autoinstall failed: {result.stderr.strip()}")
                return False
        except FileNotFoundError:
            logging.info("DKMS not installed — skipping module rebuild.")
            return True
        except Exception as e:
            logging.error(f"DKMS rebuild failed: {e}")
            return False

    @staticmethod
    def fix_libjodycode_symlink():
        """Creates libjodycode.so.3 symlink for fsck.winregfs compatibility.
        Dynamically finds the installed soversion so it works across upgrades."""
        import glob as _glob

        dst = "/usr/lib/libjodycode.so.3"
        # Find the real installed soversion (e.g. libjodycode.so.4, .so.5, etc.)
        candidates = sorted(_glob.glob(
            "/usr/lib/libjodycode.so.[0-9]*"), reverse=True)
        # Filter out the .so.3 itself and any sub-versions like .so.4.1.2
        candidates = [
            c for c in candidates if not c.endswith(".so.3") and c.count(".") == 3
        ]

        if not candidates:
            logging.debug("libjodycode not installed — skipping symlink.")
            return

        src = candidates[0]  # highest soversion available
        if os.path.exists(dst):
            current_target = os.path.realpath(dst)
            expected_target = os.path.realpath(src)
            if current_target == expected_target:
                logging.debug(
                    f"libjodycode.so.3 → {os.path.basename(src)} already correct."
                )
                return
            logging.info(
                f"Updating libjodycode.so.3 symlink: {os.path.basename(current_target)} → {os.path.basename(src)}"
            )

        try:
            subprocess.run(["sudo", "ln", "-sf", src, dst], check=True)
            logging.info(
                f"libjodycode.so.3 → {os.path.basename(src)} symlink created.")
        except Exception as e:
            logging.warning(
                f"Failed to create libjodycode symlink (non-critical): {e}")

    @staticmethod
    def fix_dracut_config():
        """Configures dracut to use /boot instead of EFI partition (prevents UKI issues)."""
        if os.path.exists(KernelManager.DRACUT_CONF):
            logging.info("Dracut configuration already exists — skipping.")
            return
        logging.info("Configuring dracut to use /boot directory...")
        content = '# Fix dracut to use /boot instead of EFI partition\nuefi="no"\nhostonly="yes"\ncompress="zstd"\n'
        try:
            tmp = "/tmp/_aio_dracut_fix.conf"
            with open(tmp, "w") as f:
                f.write(content)
            subprocess.run(
                ["sudo", "mkdir", "-p", "/etc/dracut.conf.d"], check=True)
            subprocess.run(
                ["sudo", "cp", tmp, KernelManager.DRACUT_CONF], check=True)
            os.remove(tmp)
            logging.info("Dracut configuration created successfully.")
        except Exception as e:
            logging.warning(
                f"Failed to create dracut config (non-critical): {e}")

    @staticmethod
    def fix_kernel_install_config():
        """Configures kernel-install to disable UKI and use traditional initramfs."""
        if os.path.exists(KernelManager.KERNEL_INSTALL_CONF):
            logging.info(
                "Kernel install configuration already exists — skipping.")
            return
        logging.info(
            "Configuring kernel-install to use traditional initramfs...")
        content = "layout=bls\ninitrd_generator=dracut\n"
        try:
            tmp = "/tmp/_aio_kernel_install.conf"
            with open(tmp, "w") as f:
                f.write(content)
            subprocess.run(["sudo", "mkdir", "-p", "/etc/kernel"], check=True)
            subprocess.run(
                ["sudo", "cp", tmp, KernelManager.KERNEL_INSTALL_CONF], check=True
            )
            os.remove(tmp)
            logging.info("Kernel install configuration created successfully.")
        except Exception as e:
            logging.warning(
                f"Failed to create kernel install config (non-critical): {e}"
            )

    @staticmethod
    def apply_system_fixes():
        """Applies all preventive system fixes (libjodycode, dracut, kernel-install)."""
        logging.info("--- Applying preventive system fixes ---")
        KernelManager.fix_libjodycode_symlink()
        KernelManager.fix_dracut_config()
        KernelManager.fix_kernel_install_config()
        logging.info("--- System fixes complete ---")

    @staticmethod
    def regenerate_initramfs() -> bool:
        """Regenerates initramfs for all installed kernels using dracut."""
        logging.info("Regenerating initramfs with dracut...")
        try:
            # Get list of installed kernels from /usr/lib/modules
            result = subprocess.run(
                ["ls", "/usr/lib/modules"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                encoding="utf-8",
            )
            if result.returncode != 0:
                logging.warning("Could not list kernel modules directory.")
                return False
            kernels = [
                k.strip() for k in result.stdout.strip().splitlines() if k.strip()
            ]
            if not kernels:
                logging.warning("No kernel module directories found.")
                return False
            for kver in kernels:
                vmlinuz = f"/usr/lib/modules/{kver}/vmlinuz"
                if not os.path.exists(vmlinuz):
                    continue
                logging.info(f"Regenerating initramfs for kernel {kver}...")
                ret = subprocess.run(
                    ["sudo", "dracut", "--force", "--kver", kver],
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    encoding="utf-8",
                )
                if ret.returncode == 0:
                    logging.info(f"initramfs regenerated for {kver}")
                else:
                    logging.error(
                        f"Failed to regenerate initramfs for {kver}: {ret.stderr.strip()}"
                    )
            return True
        except FileNotFoundError:
            logging.warning(
                "dracut not found — skipping initramfs regeneration.")
            return False
        except Exception as e:
            logging.error(f"initramfs regeneration failed: {e}")
            return False

    @staticmethod
    def full_kernel_upgrade():
        """
        Orchestrates a full kernel upgrade with:
        1. Pre-snapshot (snapper)
        2. System fixes (dracut, kernel-install, libjodycode)
        3. Kernel package upgrade via pacman
        4. DKMS module rebuild
        5. initramfs regeneration
        6. Post-snapshot (snapper)
        """
        logging.info("=" * 60)
        logging.info("KERNEL UPGRADE — Full orchestration starting")
        logging.info(f"Running kernel: {KernelManager.get_running_kernel()}")
        logging.info("=" * 60)

        has_update, kernel_pkgs = KernelManager.detect_kernel_update_pending()
        if not has_update:
            logging.info(
                "No pending kernel updates detected. Checking DKMS status only..."
            )
            dkms_mods = KernelManager.get_installed_dkms_modules()
            if dkms_mods:
                logging.info(f"DKMS modules found: {len(dkms_mods)}")
                for m in dkms_mods:
                    logging.info(f"  {m['raw']}")
            logging.info("No kernel upgrade needed. Done.")
            return True

        logging.info(f"Pending kernel upgrades detected:")
        for kp in kernel_pkgs:
            logging.info(f"  {kp}")

        # Step 1: Pre-snapshot
        pre_snap = KernelManager.snapper_create_pre(
            f"kernel-upgrade-pre {datetime.now().isoformat()}"
        )

        # Step 2: System fixes
        KernelManager.apply_system_fixes()

        # Step 3: Upgrade kernel packages
        logging.info("Upgrading kernel packages...")
        pkg_names = [line.split()[0] for line in kernel_pkgs]
        upgrade_cmd = ["sudo", "pacman", "-S",
                       "--needed", "--noconfirm"] + pkg_names
        try:
            subprocess.run(upgrade_cmd, check=True)
            logging.info("Kernel packages upgraded successfully.")
        except subprocess.CalledProcessError as e:
            logging.error(f"Kernel package upgrade FAILED: {e}")
            # Still create post-snapshot to capture the failed state
            KernelManager.snapper_create_post(
                pre_snap, f"kernel-upgrade-post-FAILED {datetime.now().isoformat()}"
            )
            return False

        # Step 4: DKMS rebuild
        dkms_mods = KernelManager.get_installed_dkms_modules()
        if dkms_mods:
            logging.info(f"Rebuilding {len(dkms_mods)} DKMS modules...")
            dkms_pre = KernelManager.snapper_create_pre(
                f"dkms-rebuild-pre {datetime.now().isoformat()}"
            )
            dkms_ok = KernelManager.rebuild_dkms_all()
            KernelManager.snapper_create_post(
                dkms_pre,
                f"dkms-rebuild-post {'OK' if dkms_ok else 'FAILED'} {datetime.now().isoformat()}",
            )
            if not dkms_ok:
                logging.error(
                    "DKMS rebuild had errors — check dkms status manually.")
        else:
            logging.info("No DKMS modules registered — skipping rebuild.")

        # Step 5: Regenerate initramfs
        KernelManager.regenerate_initramfs()

        # Step 6: Post-snapshot
        KernelManager.snapper_create_post(
            pre_snap, f"kernel-upgrade-post-OK {datetime.now().isoformat()}"
        )

        logging.info("=" * 60)
        logging.info("KERNEL UPGRADE — Complete")
        logging.info("=" * 60)
        return True


# --- Fast Update Module (Async) ---
class FastUpdate:
    def __init__(self):
        self.lock_file = "/var/lib/pacman/db.lck"
        self.ignore_pkgs = set()  # Packages to skip due to unresolvable deps

    def check_cmd(self, cmd):
        return (
            subprocess.run(
                f"command -v {cmd}", shell=True, capture_output=True
            ).returncode
            == 0
        )

    def force_release_lock(self):
        logging.info("Ensuring database lock is released...")
        for proc in ["pacman", "yay", "paru", "packagekitd"]:
            subprocess.run(["sudo", "pkill", "-9", proc], capture_output=True)
        if os.path.exists(self.lock_file):
            subprocess.run(["sudo", "rm", "-f", self.lock_file])

    async def run_command(self, cmd, description, silent=True, ignore_errors=False):
        logging.info(f"Running: {description}")
        process = await asyncio.create_subprocess_shell(
            cmd,
            stdout=asyncio.subprocess.PIPE if silent else None,
            stderr=asyncio.subprocess.PIPE,  # Always capture stderr for error analysis
        )
        stdout, stderr = await process.communicate()
        if process.returncode != 0:
            err = stderr.decode().strip() if stderr else "Unknown error"
            if not ignore_errors:
                logging.error(f"Command failed: {description}. Error: {err}")
            return False, err
        return True, stdout.decode().strip() if stdout else ""

    async def ensure_dependency(self, cmd, pkg):
        if not self.check_cmd(cmd):
            logging.info(
                f"Dependency '{cmd}' not found. Installing '{pkg}'...")
            self.force_release_lock()
            success, err = await self.run_command(
                f"sudo pacman -S --needed --noconfirm {pkg}",
                f"Installing {pkg}",
                silent=False,
            )
            if not success:
                logging.error(
                    f"FATAL: Failed to install dependency {pkg}: {err}")
                return False
        return True

    def _build_ignore_flags(self) -> str:
        """Returns --ignore flags for all packages in self.ignore_pkgs."""
        if not self.ignore_pkgs:
            return ""
        return " ".join(f"--ignore {pkg}" for pkg in self.ignore_pkgs)

    async def download_phase(self):
        """Downloads all updates in parallel."""
        logging.info("Starting Parallel Download Phase...")
        self.force_release_lock()
        tasks = []

        ignore = self._build_ignore_flags()
        pacman_cmd = " ".join(AUR_HELPERS["pacman"]["download"])
        if ignore:
            pacman_cmd += f" {ignore}"
        tasks.append(self.run_command(
            pacman_cmd, "Downloading Pacman updates"))

        helper = PackageManager.get_best_helper()
        if helper != "pacman" and helper in AUR_HELPERS:
            cmd = " ".join(AUR_HELPERS[helper]["download"])
            if ignore:
                cmd += f" {ignore}"
            tasks.append(
                self.run_command(
                    cmd, f"Downloading AUR updates ({helper})", ignore_errors=True
                )
            )

        results = await asyncio.gather(*tasks)
        # Combine errors if any
        all_errors = "\n".join(
            [res[1]
                for res in results if isinstance(res, tuple) and not res[0]]
        )
        if all_errors:
            return False, all_errors
        return True, ""

    async def install_phase(self):
        """Sequentially installs the downloaded updates."""
        logging.info("Starting Sequential Installation Phase...")
        self.force_release_lock()

        ignore = self._build_ignore_flags()

        # 1. System upgrade
        pacman_cmd = " ".join(AUR_HELPERS["pacman"]["upgrade"])
        if ignore:
            pacman_cmd += f" {ignore}"
        success, err = await self.run_command(
            pacman_cmd, "Installing Pacman updates", silent=False
        )
        if not success:
            return False, err

        self.force_release_lock()

        # 2. AUR upgrade
        helper = PackageManager.get_best_helper()
        if helper != "pacman" and helper in AUR_HELPERS:
            logging.info(f"Installing AUR updates ({helper})...")
            cmd = " ".join(AUR_HELPERS[helper]["upgrade"])
            if ignore:
                cmd += f" {ignore}"
            success, err = await self.run_command(
                cmd,
                f"Installing AUR updates ({helper})",
                silent=False,
                ignore_errors=True,
            )
            if not success:
                return False, err

        return True, ""

    async def ensure_blackarch_repo(self):
        """Checks if blackarch repo is configured, adds it if not."""
        logging.info("Checking BlackArch repository configuration...")
        with open(PACMAN_CONF, "r") as f:
            content = f.read()

        if "[blackarch]" not in content:
            logging.info("BlackArch repository not found. Configuring...")
            # Download strap.sh
            try:
                strap_url = "https://blackarch.org/strap.sh"
                subprocess.run(["curl", "-O", strap_url], check=True)
                subprocess.run(["chmod", "+x", "strap.sh"], check=True)
                # Run strap.sh
                subprocess.run(["sudo", "./strap.sh"], check=True)
                logging.info("BlackArch repository configured successfully.")
            except Exception as e:
                logging.error(f"Failed to configure BlackArch repo: {e}")

    async def update_keyrings(self):
        """Updates Arch and BlackArch keyrings to prevent signature/find errors."""
        logging.info("Updating keyrings...")
        keys = ["archlinux-keyring", "blackarch-keyring"]
        for key in keys:
            await self.run_command(
                f"sudo pacman -S --needed --noconfirm {key}", f"Updating {key}"
            )

    async def smart_dependency_fix(self, error_output):
        """Parses error output for missing packages or slow mirrors and tries to fix them."""
        import re

        if not error_output:
            return

        logging.info(f"Analyzing error output for auto-fix...")

        # 1. Handle "Operation too slow" or "failed retrieving file" (Mirror issues)
        if any(
            x in error_output
            for x in [
                "Operation too slow",
                "failed retrieving file",
                "failed to retrieve some files",
            ]
        ):
            logging.warning(
                "Detected slow or failing mirrors. Re-optimizing mirrorlist..."
            )
            await asyncio.to_thread(Repos.update_mirrorlist)
            return True

        # 2. Handle unresolvable dependencies (e.g. wcc needs linenoise)
        #    Track them so retry commands pass --ignore
        unresolvable_patterns = [
            r'cannot resolve "([^"]+)", a dependency of "([^"]+)"',
        ]
        found_unresolvable = False
        for pattern in unresolvable_patterns:
            matches = re.findall(pattern, error_output)
            for match in matches:
                if isinstance(match, tuple):
                    pkg = match[1]  # parent package with broken dep
                    self.ignore_pkgs.add(pkg)
                    logging.warning(
                        f"Unresolvable dep: '{match[0]}' needed by '{pkg}' — will --ignore on retry"
                    )
                    found_unresolvable = True
        if found_unresolvable:
            logging.info(f"Ignore list for retry: {self.ignore_pkgs}")
            return True

        # 3. Handle missing packages / targets not found
        patterns = [
            r"could not find all required packages: ([\w\-\.\+ ]+)",
            r"target not found: ([\w\-\.\+ ]+)",
            r"error: ([\w\-\.\+]+): not found in",
            r"-> No AUR package found for ([\w\-\.\+]+)",
        ]

        missing_pkgs = []
        for pattern in patterns:
            matches = re.findall(pattern, error_output)
            for match in matches:
                missing_pkgs.extend(match.split())

        if missing_pkgs:
            missing_pkgs = list(set(missing_pkgs))
            logging.info(
                f"Found {len(missing_pkgs)} missing targets: {missing_pkgs}. Auto-fixing..."
            )
            for pkg in missing_pkgs:
                base_name = pkg.split("-")[0]
                helper = PackageManager.get_best_helper()
                if "nodejs" in pkg:
                    await self.run_command(
                        f"sudo pacman -S --needed --noconfirm nodejs",
                        "Installing base nodejs",
                    )
                elif "llvm" in pkg:
                    await self.run_command(
                        f"sudo pacman -S --needed --noconfirm llvm",
                        "Installing latest llvm",
                    )
                else:
                    logging.info(
                        f"Attempting generic fix for {pkg} using {helper}...")
                    await self.run_command(
                        f"{helper} -S --needed --noconfirm {pkg}",
                        f"Retry install {pkg}",
                        ignore_errors=True,
                    )
            return True
        return False

    async def sync_categories(self):
        """Fetches latest categories from pacman groups and syncs with internal list."""
        logging.info("Synchronizing BlackArch categories...")
        success, output = await self.run_command(
            "pacman -Sg | grep blackarch- | awk '{print $1}' | sort -u",
            "Fetching categories",
        )
        if success and output:
            official_cats = output.splitlines()
            global CATEGORIES
            new_cats = set(official_cats) - set(CATEGORIES)
            if new_cats:
                logging.info(
                    f"New categories detected and added: {list(new_cats)}")
                CATEGORIES = sorted(list(set(CATEGORIES + official_cats)))
            else:
                logging.info("Categories are already in sync.")
        else:
            logging.warning(
                "Failed to fetch official categories. Using hardcoded list."
            )

    async def execute(self):
        logging.info("--- [Auto-Detect & Fix Phase] ---")

        # Outer snapper pair wraps the entire update operation
        async with KernelManager.async_snap_wrap("aio-update-full"):
            # Step 0: Apply preventive system fixes (dracut, kernel-install, libjodycode)
            async with KernelManager.async_snap_wrap("system-fixes"):
                await asyncio.to_thread(KernelManager.apply_system_fixes)

            # Step 0.1: Detect if kernel upgrade is pending
            kernel_pending, kernel_pkgs = await asyncio.to_thread(
                KernelManager.detect_kernel_update_pending
            )
            if kernel_pending:
                logging.info(
                    f"Kernel upgrade detected in pending updates: {[kp.split()[0] for kp in kernel_pkgs]}"
                )

            # Step 0.2: Ensure Repo & Keyrings
            async with KernelManager.async_snap_wrap("ensure-blackarch-repo"):
                await self.ensure_blackarch_repo()

            async with KernelManager.async_snap_wrap("update-keyrings"):
                await self.update_keyrings()

            # Step 0.3: Ensure Essential Metapackages
            async with KernelManager.async_snap_wrap("install-metapackages"):
                logging.info("Ensuring essential metapackages...")
                await self.run_command(
                    "sudo pacman -S --needed --noconfirm blackarch-officials",
                    "Installing blackarch-officials",
                )

            # Step 0.4: Sync Categories
            async with KernelManager.async_snap_wrap("sync-categories"):
                await self.sync_categories()

            # Step 1: Helpers
            async with KernelManager.async_snap_wrap("ensure-helpers"):
                logging.info("Checking prerequisites...")
                await asyncio.to_thread(HelperManager.ensure_helpers)
                await self.ensure_dependency("reflector", "reflector")

            # Step 2: Main update steps — each wrapped individually
            print("Starting Unified System Update...")

            async with KernelManager.async_snap_wrap("mirror-optimization"):
                print("Step: Mirror Optimization")
                await asyncio.to_thread(Repos.update_mirrorlist)

            async with KernelManager.async_snap_wrap("download-updates"):
                print("Step: Downloading Updates")
                result = await self.download_phase()
                if isinstance(result, tuple) and not result[0]:
                    await self.smart_dependency_fix(result[1])
                    await self.download_phase()

            async with KernelManager.async_snap_wrap("install-updates"):
                print("Step: Installing Updates")
                result = await self.install_phase()
                if isinstance(result, tuple) and not result[0]:
                    await self.smart_dependency_fix(result[1])
                    await self.install_phase()

            async with KernelManager.async_snap_wrap("cleanup-orphans"):
                print("Step: Cleanup Orphans")
                await self.run_command(
                    "if pacman -Qdtq >/dev/null; then sudo pacman -Rs --noconfirm $(pacman -Qdtq); fi",
                    "Orphan Cleanup",
                    silent=False,
                    ignore_errors=True,
                )

            # Post-update: Handle kernel-specific tasks if a kernel upgrade was pending
            if kernel_pending:
                logging.info("--- [Post-Update Kernel Tasks] ---")
                # DKMS rebuild with its own snapper pair
                dkms_mods = await asyncio.to_thread(
                    KernelManager.get_installed_dkms_modules
                )
                if dkms_mods:
                    async with KernelManager.async_snap_wrap("dkms-rebuild"):
                        logging.info(
                            f"DKMS modules detected ({len(dkms_mods)}), rebuilding..."
                        )
                        dkms_ok = await asyncio.to_thread(
                            KernelManager.rebuild_dkms_all
                        )
                        if not dkms_ok:
                            logging.error(
                                "DKMS rebuild had errors — check dkms status manually."
                            )
                else:
                    logging.info("No DKMS modules — skipping rebuild.")

                # Regenerate initramfs
                async with KernelManager.async_snap_wrap("regenerate-initramfs"):
                    await asyncio.to_thread(KernelManager.regenerate_initramfs)

        logging.info("Unified update complete!")


# --- Tree Module ---
class Tree:
    @staticmethod
    def print_tree(path, prefix=""):
        if not os.path.exists(path):
            print(f"{prefix}Error: Directory '{path}' not found.")
            return
        with os.scandir(path) as entries:
            for entry in entries:
                if entry.is_dir(follow_symlinks=False):
                    print(f"{prefix}{entry.name}/")
                    Tree.print_tree(entry.path, prefix + "  ")
                else:
                    print(f"{prefix}{entry.name}")


# --- Main Installer Logic ---
def run_installer():
    with KernelManager.snap_wrap("install-full"):
        with KernelManager.snap_wrap("install-ensure-helpers"):
            HelperManager.ensure_helpers()

        with KernelManager.snap_wrap("install-fix-problematic-packages"):
            PackageManager.fix_problematic_packages()

        with KernelManager.snap_wrap("install-fetch-mirrors"):
            mirrors = Repos.fetch_mirrors()
            if mirrors:
                # Write first mirror temporarily (logic from original script)
                pass

        # Try install categories
        logging.info(
            f"Preparing to install {len(CATEGORIES)} BlackArch categories...")
        for helper in AUR_HELPERS:
            if Utils.is_helper_installed(helper):
                # install everything in the CATEGORIES list
                h_config = AUR_HELPERS.get(helper)
                if not h_config or "install" not in h_config:
                    continue

                cmd = (
                    h_config["install"]
                    + CATEGORIES
                    + ["--disable-download-timeout", "--noprogressbar"]
                )
                try:
                    with KernelManager.snap_wrap(f"install-categories-{helper}"):
                        logging.info(f"Running installation with {helper}...")
                        Utils.run_command(cmd)
                    print("Installation Successful.")
                    with KernelManager.snap_wrap("install-update-mirrorlist"):
                        Repos.update_mirrorlist()
                    return
                except Exception as e:
                    logging.error(f"Installation failed with {helper}: {e}")
                    continue
        print("Installation failed or no helpers found.")


# --- CLI Entry Point ---
def main():
    parser = argparse.ArgumentParser(description="BlackArch AIO Manager")
    subparsers = parser.add_subparsers(
        dest="command", help="Available commands")

    # Subcommands
    subparsers.add_parser("install", help="Run full BlackArch installation")
    subparsers.add_parser(
        "update", help="Run unified asynchronous system update & package upgrade"
    )
    subparsers.add_parser("tree", help="Show directory tree of current path")
    subparsers.add_parser(
        "fix-helpers", help="Ensure AUR helpers are installed")
    subparsers.add_parser("mirrors", help="Update mirrorlist")
    subparsers.add_parser(
        "kernel-upgrade",
        help="Full kernel upgrade with snapper snapshots, DKMS rebuild, and initramfs regeneration",
    )
    subparsers.add_parser(
        "system-fixes",
        help="Apply preventive system fixes (dracut, kernel-install, libjodycode)",
    )

    args = parser.parse_args()

    report = {
        "timestamp": datetime.now().isoformat(),
        "command": args.command,
        "status": "pending",
        "details": {},
    }

    try:
        if args.command == "install":
            # run_installer() has its own internal snap_wrap per phase
            run_installer()
            report["status"] = "success"

        elif args.command == "update":
            # Clear any old marker
            if os.path.exists(".update_done"):
                os.remove(".update_done")
            updater = FastUpdate()
            updater.force_release_lock()
            try:
                # execute() has its own internal async_snap_wrap per step
                asyncio.run(updater.execute())
                report["status"] = "success"
            except Exception as e:
                report["status"] = "failed"
                report["details"]["error"] = str(e)
                logging.error(f"Update command failed: {e}")
            finally:
                # Create completion marker ALWAYS at the end
                with open(".update_done", "w") as f:
                    f.write(
                        f"Completed at {datetime.now().isoformat()} - Status: {report['status']}"
                    )
                logging.info(
                    f"Process finished with status: {report['status']}")

        elif args.command == "tree":
            # tree is read-only, snapshot still taken per policy
            with KernelManager.snap_wrap("tree"):
                Tree.print_tree(os.getcwd())
            report["status"] = "success"

        elif args.command == "fix-helpers":
            with KernelManager.snap_wrap("fix-helpers"):
                HelperManager.ensure_helpers()
            report["status"] = "success"

        elif args.command == "mirrors":
            with KernelManager.snap_wrap("update-mirrorlist"):
                Repos.update_mirrorlist()
            report["status"] = "success"

        elif args.command == "kernel-upgrade":
            # full_kernel_upgrade() has its own internal snap_wrap pairs
            logging.info("Running full kernel upgrade orchestration...")
            success = KernelManager.full_kernel_upgrade()
            report["status"] = "success" if success else "failed"
            report["details"]["kernel"] = KernelManager.get_running_kernel()

        elif args.command == "system-fixes":
            with KernelManager.snap_wrap("system-fixes"):
                logging.info("Applying preventive system fixes...")
                KernelManager.apply_system_fixes()
            report["status"] = "success"

        else:
            parser.print_help()
            report["status"] = "no_command"

    except KeyboardInterrupt:
        report["status"] = "aborted"
        print("\nOperation cancelled by user.")
    except Exception as e:
        report["status"] = "error"
        report["details"]["exception"] = str(e)
        logging.exception("Unexpected error:")

    # Output Report
    print("\n--- Execution Report ---")
    print(json.dumps(report, indent=4))


if __name__ == "__main__":
    main()
