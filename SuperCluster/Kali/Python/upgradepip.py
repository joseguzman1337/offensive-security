import subprocess
import re
from tqdm import tqdm
from colorama import Fore, Style
import sys
from mpi4py import MPI

# Install missing type stubs as a prerequisite
def install_missing_stubs():
    try:
        # Clean Python Cache & Install Python Dependencies
        result = subprocess.run([sys.executable, '-m', 'pip', 'show', 'types-colorama', 'types-tqdm'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
        if result.stderr and 'No such file or directory' not in result.stderr:
            print(f"{Fore.YELLOW}Cleaning Python Cache & Installing Python Dependencies...{Style.RESET_ALL}")
            subprocess.run(['pip', 'cache', 'purge'], check=True)
            subprocess.run(['pip', 'install', '-r', 'requirements.txt', '-U', '-q', '--index', '--wheel', '--check', '--require-virtualenv', '--python 3.10.11', '--completion', '--upgrade', '--ignore-installed', '--no-warn-script-location', '--force-reinstall'], check=True)

    except subprocess.CalledProcessError as e:
        if e.stderr and 'No such file or directory' not in e.stderr:
            print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}An unexpected error occurred: {e}{Style.RESET_ALL}")


# Function to determine the installation method and upgrade a specific package
def upgrade_package(package):
    try:
        # Get the installation method (pip, pip2, pip3, pipx)
        method_result = subprocess.run(["pip", "show", package], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        installation_method = None

        if "pipx" in method_result.stdout:
            installation_method = "pipx"
        elif "pip3" in method_result.stdout:
            installation_method = "pip3"
        elif "pip2" in method_result.stdout:
            installation_method = "pip2"
        elif "pip" in method_result.stdout:
            installation_method = "pip"

        if installation_method:
            # Check if the package is already installed using the determined method
            installed_result = subprocess.run([installation_method, "show", package], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

            if "Version" in installed_result.stdout:
                # Upgrade the package using the determined installation method
                subprocess.check_call([installation_method, "install", "--upgrade", package], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                print(f"{Fore.GREEN}Successfully upgraded {package} using {installation_method}{Style.RESET_ALL}")
            else:
                print(f"{Fore.YELLOW}{package} not installed using {installation_method}{Style.RESET_ALL}")
        else:
            print(f"{Fore.RED}Failed to determine the installation method for {package}{Style.RESET_ALL}")
    except subprocess.CalledProcessError as e:
        if 'No such file or directory' not in e.stderr:
            print(f"{Fore.RED}Failed to upgrade {package}: {e}{Style.RESET_ALL}")
    except Exception as e:
        print(f"{Fore.RED}An unexpected error occurred while upgrading {package}: {e}{Style.RESET_ALL}")


# Function to upgrade a specific package and return success or failure with a RGB progress bar
def upgrade_package_result(package, progress_bar=None):
    try:
        result = subprocess.run(["pip", "install", "--upgrade", package], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=False)
        if result.stderr and 'No such file or directory' not in result.stderr:
            if progress_bar:
                progress_bar.set_postfix({"Status": f"Failed to upgrade {package}"})
            return False, f"{Fore.RED}Failed to upgrade {package}: {result.stderr}{Style.RESET_ALL}"
        if progress_bar:
            progress_bar.set_postfix({"Status": f"Successfully upgraded {package}"})
        return True, f"{Fore.GREEN}Successfully upgraded {package}{Style.RESET_ALL}"
    except subprocess.CalledProcessError as e:
        if e.stderr and 'No such file or directory' not in e.stderr:
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


# Function to upgrade all installed packages and provide a summary with a RGB progress bar
def upgrade_all_packages(comm, comm_rank=0, comm_size=1):
    success_count = 0
    failure_count = 0
    failure_messages = []

    try:
        # Get a list of installed packages
        pip_list = subprocess.Popen(["pip", "list", "--format=freeze"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = pip_list.communicate()

        # Check if the command executed successfully
        if pip_list.returncode == 0:
            installed_packages = [line.split("==")[0] for line in out.decode("utf-8").split('\n') if line]

            # Distribute packages among MPI processes
            packages_per_process = len(installed_packages) // comm_size
            start_idx = comm_rank * packages_per_process
            end_idx = (comm_rank + 1) * packages_per_process if comm_rank < comm_size - 1 else len(installed_packages)

            # Initialize tqdm progress bar with a shorter description and CPU number
            progress_bar = tqdm(installed_packages[start_idx:end_idx], desc=f"{Fore.CYAN}Using CPU # {comm_rank + 1}/{comm_size}{Style.RESET_ALL}", unit="pkg", bar_format="{l_bar}{bar:10}{r_bar}", position=comm_rank)

            # Upgrade each installed package with tqdm progress bar
            for package in progress_bar:
                success, message = upgrade_package_result(package, progress_bar)
                if success:
                    success_count += 1
                else:
                    failure_count += 1
                    failure_messages.append(message)

            # Close the tqdm progress bar
            progress_bar.close()

            # Add three empty lines after printing CPU # in the summary
            if comm_rank == 0:
                print(f"{Fore.CYAN}Using CPU # {comm_rank + 1}/{comm_size}{Style.RESET_ALL}")
                print("\n" * 3)

            # Gather results from all processes
            success_counts = comm.gather(success_count, root=0)
            failure_counts = comm.gather(failure_count, root=0)
            failure_messages_all = comm.gather(failure_messages, root=0)

            if comm_rank == 0:
                # Print summary
                total_success_count = sum(success_counts)
                total_failure_count = sum(failure_counts)
                print(f"\n{Fore.GREEN}Summary:{Style.RESET_ALL}")
                print(f"{Fore.GREEN}Successfully upgraded {total_success_count} packages.{Style.RESET_ALL}")
                print(f"{Fore.RED}Failed to upgrade {total_failure_count} packages.{Style.RESET_ALL}")
                for failure_messages in failure_messages_all:
                    for failure_message in failure_messages:
                        print(failure_message)

        else:
            print(f"{Fore.RED}Failed to get the list of installed packages.{Style.RESET_ALL}")

    except Exception as e:
        print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")


# Main function to upgrade all installed packages
def main():
    try:
        # Initialize MPI
        comm = MPI.COMM_WORLD
        comm_rank = comm.Get_rank()
        comm_size = comm.Get_size()

        # Install missing type stubs as a prerequisite
        if 'requirements.txt' not in sys.argv:
            install_missing_stubs()

        # Run the command to install a package and capture the output
        result = subprocess.run(['pip', 'install', '-r', 'requirements.txt', '-U', '-q', '--index', '--wheel', '--check', '--require-virtualenv', '--python 3.10.11', '--completion', '--upgrade', '--ignore-installed', '--no-warn-script-location', '--force-reinstall'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Check if the warning message is present in the output
        if "No metadata found" in result.stderr:
            # Extract the package name from the warning using regex
            match = re.search(r"'([^']+)'", result.stderr)
            if match:
                package_with_issue = match.group(1)
                print(f"{Fore.YELLOW}Handling metadata for {package_with_issue}{Style.RESET_ALL}")
                success, message = upgrade_package_result(package_with_issue)
                if not success:
                    print(f"{Fore.RED}Failed to handle metadata for {package_with_issue}: {message}{Style.RESET_ALL}")
        else:
            # Continue with upgrading all installed packages if no metadata issue
            upgrade_all_packages(comm, comm_rank, comm_size)

    except Exception as e:
        print(f"{Fore.RED}An error occurred: {e}{Style.RESET_ALL}")

# Call the main function if the script is executed
if __name__ == "__main__":
    main()
