#!/usr/bin/env python3
"""Automates BlackArch installation on Arch Linux."""

import logging
import subprocess

import blackarch_packages
import blackarch_repos
import missing_helpers
import problematic_packages
import utils  # Import the utils module

# --- Global Variables ---
LOG_FILE = "/tmp/blackarch_installer.log"

AUR_HELPERS = missing_helpers.AUR_HELPERS

# --- Main Execution ---
with open(LOG_FILE, "w"):  # Clear log file
    pass

logging.basicConfig(
    filename=LOG_FILE,
    level=logging.DEBUG,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# Install any missing helpers
missing_helpers.main()
problematic_packages.fix_problematic_packages()
mirrors = blackarch_repos.fetch_mirrors()

current_country = get_current_country()

for mirror in mirrors:
    logging.info("Trying mirror: %s", mirror)
    with open(blackarch_repos.MIRRORLIST_FILE, "w", encoding="utf-8") as file:
        file.write(f"Server = {mirror}\n")  # Use only the current mirror

    try:
        utils.run_command(["sudo", "pacman", "-Sy"], retries=3)  # Corrected utils call
    except subprocess.CalledProcessError:
        logging.warning("Mirror %s failed, trying next...", mirror)
        continue  # Go to the next mirror if this one fails

    # If the mirror works, proceed with installations
    for helper in missing_helpers.AUR_HELPERS:
        if not utils.is_helper_installed(helper):  # Corrected utils call
            logging.warning("Helper %s not installed...", helper)
            continue

        print(f"Trying AUR helper: {helper}")
        install_command = (
            missing_helpers.AUR_HELPERS[helper]
            + blackarch_packages.PACKAGES_TO_INSTALL
            + [
                "--needed",
                "--noconfirm",
                "--disable-download-timeout",
                "--noprogressbar",
            ]
        )

        try:
            utils.run_command(
                install_command, suppress_output=True
            )  # Corrected utils call
            print("All packages installed successfully!")

            verify_blackarch_categories()
            reflector.update_mirrorlist(current_country)
            return  # Exit if installation is successful
        except subprocess.CalledProcessError:
            pass  # Move on to the next helper if this one fails

logging.error("No working mirror found. Check mirrorlist & connection.")
print("No working mirror found. Check the log file for details.")
