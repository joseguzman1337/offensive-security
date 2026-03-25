import subprocess
from tqdm import tqdm
from colorama import Fore, Style
import sys
from multiprocessing import Lock

# Define a lock to prevent conflicts during installation
install_lock = Lock()

# Install missing type stubs as a prerequisite
def install_missing_stubs():
    try:
        with install_lock:
            # Clean Python Cache & Install Python Dependencies
            result = subprocess.run(['yay', '-S', 'python-colorama', 'python-tqdm'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
            if result.stderr and 'No such file or directory' not in result.stderr:
                print(f"{Fore.YELLOW}Cleaning Python Cache & Installing Python Dependencies...{Style.RESET_ALL}")
                subprocess.run(['yay', '-Scc', '--noconfirm'], check=True)

    except subprocess.CalledProcessError as e:
        if e.stderr and 'No such file or directory' not in e.stderr:
            print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}An unexpected error occurred: {e}{Style.RESET_ALL}")

# Function to determine the installation method and upgrade a specific package
def upgrade_package(package):
    try:
        # Check if the package is installed using pacman
        installed_result = subprocess.run(['pacman', '-Q', package], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        if installed_result.returncode == 0:
            # Upgrade the package using pacman
            subprocess.check_call(['sudo', 'pacman', '-Syu', package], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            print(f"{Fore.GREEN}Successfully upgraded {package} using pacman{Style.RESET_ALL}")
        else:
            print(f"{Fore.YELLOW}{package} not installed using pacman{Style.RESET_ALL}")

    except subprocess.CalledProcessError as e:
        if 'No such file or directory' not in e.stderr:
            print(f"{Fore.RED}Failed to upgrade {package}: {e}{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}An unexpected error occurred while upgrading {package}: {e}{Style.RESET_ALL}")

# Function to upgrade a specific package and return success or failure with a tqdm progress bar
def upgrade_package_result(package, progress_bar=None):
    try:
        # Upgrade the package using pacman
        subprocess.check_call(['sudo', 'pacman', '-Syu', package], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        if progress_bar:
            progress_bar.set_postfix({"Status": f"Successfully upgraded {package}"})
        return True, f"{Fore.GREEN}Successfully upgraded {package}{Style.RESET_ALL}"

    except subprocess.CalledProcessError as e:
        if 'No such file or directory' not in e.stderr:
            if progress_bar:
                progress_bar.set_postfix({"Status": f"Failed to upgrade {package}"})
            return False, f"{Fore.RED}Failed to upgrade {package}: {e.stderr}{Style.RESET_ALL}"
        if progress_bar:
            progress_bar.set_postfix({"Status": f"Failed to upgrade {package}"})
        return False, f"{Fore.RED}Failed to upgrade {package}: {e}{Style.RESET_ALL}"

    except Exception as e:
        if progress_bar:
            progress_bar.set_postfix({"Status": f"An unexpected error occurred while upgrading {package}"})
        return False, f"{Fore.RED}An unexpected error occurred while upgrading {package}: {e}{Style.RESET_ALL}"

# Function to upgrade all installed packages and provide a summary with a tqdm progress bar
def upgrade_all_packages():
    success_count = 0
    failure_count = 0
    failure_messages = []

    try:
        # Get a list of installed packages using pacman
        with install_lock:
            pacman_list = subprocess.Popen(['pacman', '-Qqe'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = pacman_list.communicate()

        # Check if the command executed successfully
        if pacman_list.returncode == 0:
            installed_packages = [line.strip() for line in out.decode("utf-8").split('\n') if line]

            # Initialize tqdm progress bar
            progress_bar = tqdm(installed_packages, desc="Upgrading packages", unit="pkg", bar_format="{l_bar}{bar:10}{r_bar}")

            # Upgrade each installed package with tqdm progress bar in parallel using OpenMPI
            for package in progress_bar:
                success, message = upgrade_package_result(package, progress_bar)
                if success:
                    success_count += 1
                else:
                    failure_count += 1
                    failure_messages.append(message)

            # Close the tqdm progress bar
            progress_bar.close()

            # Print summary
            print(f"\n{Fore.GREEN}Summary:{Style.RESET_ALL}")
            print(f"{Fore.GREEN}Successfully upgraded {success_count} packages.{Style.RESET_ALL}")
            print(f"{Fore.RED}Failed to upgrade {failure_count} packages.{Style.RESET_ALL}")
            for failure_message in failure_messages:
                print(failure_message)

        else:
            print(f"{Fore.RED}Failed to get the list of installed packages.{Style.RESET_ALL}")

    except Exception as e:
        print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")

# Main function to upgrade all installed packages
def main():
    try:
        # Install missing type stubs as a prerequisite
        if 'requirements.txt' not in sys.argv:
            install_missing_stubs()

        # Upgrade all installed packages using pacman in parallel
        upgrade_all_packages()

    except Exception as e:
        print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")

# Call the main function if the script is executed
if __name__ == "__main__":
    main()
