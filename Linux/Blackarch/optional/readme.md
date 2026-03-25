# BlackArch Installer for Arch Linux

This Python script automates the installation of BlackArch tools on an existing Arch Linux system. It streamlines the process, handles potential errors, and provides useful features to make installation easier.

## Features

- **Handles Ignored Packages:** Automatically attempts to fix packages listed in the `IgnorePkg` section of your `pacman.conf` file.
- **Mirror Selection:** Intelligently selects the fastest working BlackArch mirror to use for installation.
- **Dependency Resolution:** Automatically resolves missing dependencies for BlackArch tools.
- **Category Verification:** Confirms that all desired BlackArch categories are installed successfully.
- **Pre-Installation Tasks:** Performs essential tasks like updating mirrorlists and cleaning the Pacman cache before installation.
- **Location-Based Mirrors:** Automatically detects your location to prioritize nearby mirrors for faster downloads (requires `geocoder` library).
- **Error Handling and Logging:** Provides comprehensive error handling and logging to the `/tmp/blackarch_installer.log` file for debugging.
- **AUR Helper Support:** Iterates using popular AUR helpers like `pacman`, `yay`, `paru`, and `pacaur`.

## Requirements

- **Arch Linux:** This script is designed for Arch Linux or Arch-based distributions.
- **Python 3 and Anaconda:** You'll need Python 3 and Anaconda (https://www.anaconda.com/download) installed on your system.
- **Python Libraries:**
  - `requests`
  - `geocoder`
  - `configparser`
- **AUR Helper:** Will use the following AUR helpers:
  - `pacman`
  - `yay`
  - `paru`
  - `pacaur`

## Usage

1. **Clone/Download the Repository:** Clone or download the repository containing this script and the required `blackarch_packages.py` file.

2. **`blackarch_packages.py`:** In this file, are all the BlackArch packages and categories to be installed.

3. **Run the Script:** Make the script executable and run it using `sudo`:

   ```ShellSession
   chmod +x blackarch_installer.py && sudo ./blackarch_installer.py
   ```
