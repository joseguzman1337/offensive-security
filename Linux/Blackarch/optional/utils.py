import logging
import os
import subprocess
import tempfile
import time
import typing

# --- Global Variables ---
PACMAN_CONF = "/etc/pacman.conf"
LOG_FILE = os.path.join(tempfile.gettempdir(), "blackarch_installer.log")

AUR_HELPERS = {
    "yay": ["yay", "-S"],
    "paru": ["paru", "-S"],
    "pacaur": ["pacaur", "-S"],
    "pacman": ["sudo", "pacman", "-S"],
}


def run_command(
    command: list[str],
    suppress_output: bool = False,
    retries: int = 3,
) -> typing.Optional[str]:
    """Runs a shell command with optional retries and output suppression.

    Args:
        command: The command to run as a list of strings.
        suppress_output: Whether to suppress output. Defaults to False.
        retries: Number of retries if the command fails. Defaults to 3.

    Returns:
        The command's output if successful, otherwise None.
    """

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
                "Command '%s' failed (attempt %d/%d):",
                " ".join(command),
                attempt + 1,
                retries,
            )
            logging.warning("Error output:\n%s", e.stdout)  # Log error output
            if attempt < retries - 1:
                time.sleep(5)
            else:
                raise


def is_helper_installed(helper: str) -> bool:
    """Checks if the given AUR helper is installed."""
    if helper == "pacman":
        return True
    try:
        subprocess.run([helper, "--version"], check=True, stdout=subprocess.DEVNULL)
        return True
    except FileNotFoundError:
        return False
