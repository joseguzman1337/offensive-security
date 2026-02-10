# BlackArch All-In-One (AIO) Manager

This tool consolidates multiple BlackArch maintenance scripts into a single, robust, and fully automated utility. It handles installation, updates, mirror management, and directory visualization with standardized JSON reporting and 100% automation.

## Features

*   **Unified CLI:** Single entry point (`blackarch_aio.py`) for all maintenance tasks.
*   **Optimized Update:** Single-pass, asynchronous system upgrade (Core + AUR) with parallel downloads.
*   **Auto-Healing:** Proactively installs missing dependencies, updates keyrings, and configures repositories if missing.
*   **Geo-Proximity Mirrors:** Automatically optimizes mirrorlists using geolocation and speed testing via `reflector`.
*   **Smart Lock Management:** Automatically handles `pacman` database locks and terminates conflicting processes.
*   **JSON Reporting:** Standardized JSON output for every execution, enabling easy automation and monitoring.
*   **Zero-Config:** 100% human-intervention-free by design.

## Usage

Make the script executable:
```bash
chmod +x blackarch_aio.py
```

### Commands

1.  **Full Installation:**
    Installs all BlackArch categories, configures repositories, and sets up helpers.
    ```bash
    ./blackarch_aio.py install
    ```

2.  **Unified System Update:**
    Performs mirror optimization, parallel package downloads, and a full system upgrade (Core + AUR).
    ```bash
    ./blackarch_aio.py update
    ```

3.  **Directory Tree:**
    Visualizes the folder structure of the current workspace.
    ```bash
    ./blackarch_aio.py tree
    ```

4.  **Fix Helpers:**
    Ensures all supported AUR helpers (`yay`, `paru`, `trizen`, `pikaur`, etc.) are installed and ready.
    ```bash
    ./blackarch_aio.py fix-helpers
    ```

5.  **Update Mirrors:**
    Manually triggers mirrorlist optimization based on proximity and transfer rates.
    ```bash
    ./blackarch_aio.py mirrors
    ```

### Real-Time Monitoring

You can monitor the update progress, system metrics, and logs in real-time with 100% accuracy using this command:

```bash
while true; do clear; echo "=== BLACKARCH AIO MONITOR ==="; PID=$(pgrep -f "blackarch_aio.py update" | head -n 1); if [ -f ".update_done" ]; then echo "STATUS: COMPLETED ($(cat .update_done))"; elif [ -n "$PID" ]; then echo "STATUS: RUNNING (PID: $PID)"; ps -p $PID -o %cpu,%mem,etime,rss --no-headers | awk '{print "CPU: "$1"% | MEM: "$2"% | TIME: "$3" | RSS: "$4"KB"}'; else echo "STATUS: IDLE / NOT STARTED"; fi; echo "-----------------------------"; tail -n 15 blackarch_aio_out.log; sleep 5; done
```

## Logic Migration

This script integrates and improves logic from:
*   `blackarch_installer.py` (Core installation flow)
*   `fast_update.py` (Async I/O and locking strategy)
*   `reflector.py` & `blackarch_repos.py` (Advanced mirror management)
*   `utils.py`, `helpers.py`, `missing_helpers.py` (Helper/Package utilities)
*   `problematic_packages.py` (Retry/Ignore logic)
*   `folder_tree_*.py` (Tree visualization)

## Output Format

Every command concludes with a standardized JSON report:

```json
{
    "timestamp": "2026-02-10T15:42:35.112268",
    "command": "update",
    "status": "success",
    "details": {}
}
```