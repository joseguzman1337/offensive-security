import requests

MIRRORS_URL = "https://github.com/BlackArch/blackarch/blob/master/mirror/mirror.lst"


def fetch_mirrors():
    response = requests.get(MIRRORS_URL)
    response.raise_for_status()  # Raise an exception for HTTP errors

    # Extract mirror URLs from the raw text content
    mirrors = []
    for line in response.text.splitlines():
        if line.startswith("Server = "):
            mirrors.append(
                line.split("#")[0].strip()[8:]
            )  # Remove comments and leading/trailing spaces
    return mirrors
