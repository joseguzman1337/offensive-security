"""Download google/api"""

import os

import requests


def download_file(url, folder_name):
    """
    Downloads a file from a URL and saves it to a specified folder.

    Args:
        url: The URL of the file to download.
        folder_name: The name of the folder to save the file to.
    """
    if not os.path.exists(folder_name):
        os.makedirs(folder_name)

    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()

        file_name = os.path.basename(url.split("/")[-1])
        file_path = os.path.join(folder_name, file_name)
        if not os.path.realpath(file_path).startswith(os.path.realpath(folder_name)):
            print(f"Skipping {url}: path traversal detected")
            return

        with open(file_path, "wb") as file:
            for chunk in response.iter_content(chunk_size=8192):
                file.write(chunk)

        print(f"Downloaded: {file_name} to {file_path}")

    except requests.exceptions.RequestException as e:
        print(f"Error downloading {url}: {e}")


def print_directory_tree(folder_name):
    """
    Prints the full directory tree structure with filenames and extensions.

    Args:
        folder_name: The name of the folder to print the tree for.
    """
    for root, dirs, files in os.walk(folder_name):
        level = root.replace(folder_name, "").count(os.sep)
        indent = " " * 4 * (level)
        print(f"{indent}{os.path.basename(root)}/")
        subindent = " " * 4 * (level + 1)
        for f in files:
            print(f"{subindent}{f}")


# URLs and their corresponding folder paths
files_to_download = {
    "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto": "google/api",
    "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto": "google/api",
    "https://raw.githubusercontent.com/protocolbuffers/protobuf/main/src/google/protobuf/descriptor.proto": "google/protobuf",
    "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/client.proto": "google/api",
    "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/field_behavior.proto": "google/api",
    "https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/launch_stage.proto": "google/api",
}

# Download the files
for url, folder_name in files_to_download.items():
    download_file(url, folder_name)

# Print the directory tree
print_directory_tree("google")
