import logging
import subprocess

import geocoder
import requests


def update_mirrorlist(country: str = None) -> None:
    """Updates the pacman mirrorlist using reflector, optionally filtering by country.

    Args:
        country (str, optional): The country code to filter mirrors by (e.g., "US"). Defaults to None, which means all mirrors will be considered.
    """

    if not country:
        try:
            g = geocoder.ip("me")
            country = g.country
            logging.info("Detected country: %s", country)
        except (
            requests.exceptions.RequestException,
            geocoder.api.exceptions.GeocoderError,
        ) as e:
            logging.warning("Could not detect country, using all mirrors: %s", e)

    # Command arguments for reflector
    reflector_args = [
        "--latest",
        "10",
        "--sort",
        "rate",
        "--save",
        "/etc/pacman.d/mirrorlist",
        "--protocol",
        "https",
        "--age",
        "24",
        "--score",
        "100",
        "--fastest",
        "100",
        "--latest",
        "50",
    ]

    if country:
        reflector_args.extend(["--country", country])

    logging.info("Updating mirrorlist with arguments: %s", reflector_args)

    try:
        result = subprocess.run(
            ["reflector"]
            + reflector_args,  # Removed 'sudo' for clarity and potential security
            capture_output=True,
            text=True,
            check=True,
        )
        logging.info("Mirrorlist updated successfully.\nOutput: %s", result.stdout)
    except subprocess.CalledProcessError as e:
        logging.error(
            "Error updating mirrorlist:\n%s", e.stderr
        )  # Log the stderr on error
