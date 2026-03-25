import os


def print_directory_tree(path, prefix=""):
    """Prints the directory tree structure starting from the given path.

    Args:
        path (str): The path to the directory to print the tree for.
        prefix (str, optional): Prefix used for indentation in the tree output. Defaults to "".
    """

    if not os.path.exists(path):
        print(f"{prefix}Error: Directory '{path}' not found.")
        return

    with os.scandir(path) as entries:
        for entry in entries:
            if entry.is_dir(follow_symlinks=False):  # Only display directories
                print(f"{prefix}{entry.name}/")
                # Recursively print subdirectories with increased indentation
                print_directory_tree(entry.path, prefix + "  ")


if __name__ == "__main__":
    # Get the current working directory
    current_directory = os.getcwd()
    print_directory_tree(current_directory)
