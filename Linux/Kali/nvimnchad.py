import os
import shutil  # Import shutil for directory deletion
import subprocess


def install_package(nvim_path, package_name):
    """Installs a package if it's not already present."""
    package_path = os.path.expanduser(
        f"~/.local/share/nvim/site/pack/packer/start/{package_name}.nvim"
    )
    if os.path.exists(package_path):
        print(f"Removing existing {package_name}.nvim directory...")
        shutil.rmtree(package_path)  # Delete the directory

    print(f"Installing {package_name}...", end="")  # No newline
    # Use git to clone the package repository
    try:
        subprocess.run(
            [
                "git",
                "clone",
                "--filter=blob:none",
                "--depth",
                "1",
                f"https://github.com/williamboman/{package_name}.nvim",
                package_path,
            ],
            check=True,
            stdout=subprocess.DEVNULL,  # Hide stdout
            stderr=subprocess.DEVNULL,  # Hide stderr
        )
        print(" Success!")  # Print success message on the same line
    except subprocess.CalledProcessError:
        print(" Failed!")  # Print fail message on the same line


def main():
    """Main function to execute the installation process."""
    # Download and extract Neovim
    nvim_version = "v0.10.2"
    nvim_tarball = f"nvim-linux64.tar.gz"
    nvim_folder = f"nvim-linux64"
    nvim_path = f"./{nvim_folder}/bin/nvim"

    if not os.path.exists(nvim_folder):
        print(f"Downloading and extracting Neovim {nvim_version}...")
        subprocess.run(
            [
                "wget",
                f"https://github.com/neovim/neovim/releases/download/{nvim_version}/{nvim_tarball}",
            ],
            check=True,
        )
        subprocess.run(["tar", "xzf", nvim_tarball], check=True)

    # Install packer.nvim if not present
    packer_path = os.path.expanduser(
        "~/.local/share/nvim/site/pack/packer/start/packer.nvim"
    )
    if not os.path.exists(packer_path):
        print("Installing packer.nvim...", end="")
        try:
            subprocess.run(
                [
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    "https://github.com/wbthomason/packer.nvim",
                    packer_path,
                ],
                check=True,
                stdout=subprocess.DEVNULL,  # Hide stdout
                stderr=subprocess.DEVNULL,  # Hide stderr
            )
            print(" Success!")
        except subprocess.CalledProcessError:
            print(" Failed!")

    # Install mason.nvim and mason-lspconfig.nvim if not present
    install_package(nvim_path, "mason")
    install_package(nvim_path, "mason-lspconfig")

    # Set up mason.nvim and mason-lspconfig.nvim, including ensure_installed
    try:
        subprocess.run(
            [
                nvim_path,
                "--headless",
                "-c",
                "lua require('mason').setup(); require('mason-lspconfig').setup({ ensure_installed = { 'clangd', 'sumneko_lua' } })",
                "+qall",
            ],
            check=True,
            stdout=subprocess.DEVNULL,  # Hide stdout
            stderr=subprocess.DEVNULL,  # Hide stderr
        )
    except subprocess.CalledProcessError:
        print("Error setting up mason.nvim and mason-lspconfig.nvim")

    print("Dependencies and packages installed successfully!")


if __name__ == "__main__":
    main()
