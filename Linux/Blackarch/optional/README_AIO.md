# BlackArch All-In-One (AIO) Manager

This tool consolidates multiple BlackArch maintenance scripts into a single, robust, and fully automated utility. It handles installation, updates, mirror management, and directory visualization with standardized JSON reporting.

## Features

- **Unified CLI:** Single entry point (`blackarch_aio.py`) for all tasks.
- **Fast Update:** Asynchronous, parallelized system update with database lock management and orphan cleanup.
- **Auto-Healing:** Automatically installs missing Python dependencies (`requests`, `tqdm`, etc.) and system tools (`reflector`).
- **Resilient Installation:** Tries multiple mirrors and AUR helpers (`yay`, `paru`, `pacaur`) to ensure successful package installation.
- **JSON Reporting:** Outputs a standardized JSON report after every execution for automation integration.
- **Zero-Config:** Works out of the box with sensible defaults.

## Usage

Make the script executable:

```bash
chmod +x blackarch_aio.py
```

### Commands

1.  **Full Installation:**
    Installs BlackArch packages, helpers, and configures mirrors.

    ```bash
    ./blackarch_aio.py install
    ```

2.  **Unified System Update:**
    Runs the optimized asynchronous updater (downloads updates in parallel, then installs), followed by a granular package-by-package upgrade pass.

    ```bash
    ./blackarch_aio.py update
    ```

3.  **Directory Tree:**
    Displays the folder structure of the current directory.

    ```bash
    ./blackarch_aio.py tree
    ```

4.  **Fix Helpers:**
    Ensures `yay`, `paru`, or `pacaur` are installed.

    ```bash
    ./blackarch_aio.py fix-helpers
    ```

5.  **Update Mirrors:**
    Refreshes the mirror list using `reflector` based on geolocation.
    ```bash
    ./blackarch_aio.py mirrors
    ```

### Real-Time Monitoring

You can monitor the update progress, system metrics, and logs in real-time using this command:

```bash
while true; do clear; echo "=== BLACKARCH AIO MONITOR ==="; PID=$(pgrep -f "blackarch_aio.py update" | head -n 1); if [ -n "$PID" ]; then echo "STATUS: RUNNING (PID: $PID)"; ps -p $PID -o %cpu,%mem,etime,rss --no-headers | awk '{print "CPU: "$1"% | MEM: "$2"% | TIME: "$3" | RSS: "$4"KB"}'; else echo "STATUS: NOT FOUND"; fi; echo "-----------------------------"; tail -n 15 blackarch_aio_out.log; sleep 5; done
```

## Logic Migration

This script integrates logic from:

- `blackarch_installer.py` (Main flow)
- `fast_update.py` (Async I/O, locking logic)
- `upgradepip.py` (Package iteration)
- `reflector.py` & `blackarch_repos.py` (Mirror handling)
- `utils.py`, `helpers.py`, `missing_helpers.py` (Utilities)
- `folder_tree_*.py` (Tree visualization)

## Output Format

Every command ends with a JSON report:

```json
{
  "timestamp": "2026-02-10T13:30:00.123456",
  "command": "update",
  "status": "success",
  "details": {}
}
```
