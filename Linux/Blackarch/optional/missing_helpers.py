import logging
import os
import subprocess

AUR_HELPERS = {
    "yay": ["sudo", "pacman", "-S", "--needed", "yay"],
    "paru": ["yay", "-S", "--needed", "paru"],
    "pacaur": ["yay", "-S", "--needed", "pacaur"],
}


def run_command(command: list[str]) -> bool:
    """Runs a shell command and returns True if successful, False otherwise."""
    try:
        subprocess.run(command, check=True)
        return True
    except subprocess.CalledProcessError:
        logging.error(f"Command failed: {' '.join(command)}")
        return False


def is_helper_installed(helper: str) -> bool:
    """Checks if the given AUR helper is installed."""
    if helper == "pacman":
        return True
    try:
        subprocess.run([helper, "--version"], check=True, stdout=subprocess.DEVNULL)
        return True
    except FileNotFoundError:
        return False


def install_helper_if_missing(helper: str, command: list[str]):
    """Installs a helper if it's not found on the system."""
    if not is_helper_installed(helper):
        logging.info(f"AUR helper '{helper}' not found. Installing...")
        if run_command(command):
            logging.info(f"Successfully installed '{helper}'.")
        else:
            logging.error(f"Failed to install '{helper}'. Check the logs for details.")


def main():
    """Main function to install missing helpers."""
    # Set up logging
    logging.basicConfig(
        filename="/tmp/helper_installer.log",  # You can customize the log file path
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )

    # Install yay using pacman (if not already installed)
    install_helper_if_missing("yay", ["sudo", "pacman", "-S", "--needed", "yay"])

    # Install other helpers using yay
    for helper, command in AUR_HELPERS.items():
        install_helper_if_missing(helper, command)


if __name__ == "__main__":
    main()
