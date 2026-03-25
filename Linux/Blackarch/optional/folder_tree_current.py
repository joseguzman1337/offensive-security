import os


def print_directory_tree(path):
    """Prints the immediate contents of a directory."""
    entries = list(os.scandir(path))  # Convert to list to get the last entry
    for index, entry in enumerate(entries):
        if entry.is_file():
            pipe = "└── " if index == len(entries) - 1 else "├── "
            print(f"{pipe}{entry.name}")
        elif entry.is_dir():
            pipe = "└── " if index == len(entries) - 1 else "├── "
            print(f"{pipe}{entry.name}/")


if __name__ == "__main__":
    current_directory = os.getcwd()
    print("Blackarch/")
    print_directory_tree(current_directory)
