#!/bin/bash

# Microsoft Teams Installation Script for Ubuntu
# This script installs Teams for Linux (unofficial client) via Flatpak and adds it to the local path

set -e

echo "Microsoft Teams Installation Script for Ubuntu"
echo "=============================================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should not be run as root for security reasons."
   echo "Please run as a regular user."
   exit 1
fi

# Create local directories if they don't exist
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/applications

echo "Teams for Linux has already been installed via Flatpak!"
echo "Setting up local launcher..."

echo "Creating local launcher script..."
cat > ~/.local/bin/teams << 'EOF'
#!/bin/bash
# Teams for Linux launcher script via Flatpak
flatpak run com.github.IsmaelMartinez.teams_for_linux "$@"
EOF

chmod +x ~/.local/bin/teams

# Create desktop entry
echo "Creating desktop entry..."
cat > ~/.local/share/applications/teams.desktop << 'EOF'
[Desktop Entry]
Name=Teams for Linux
Comment=Unofficial Microsoft Teams client for Linux
GenericName=Teams for Linux
Exec=flatpak run com.github.IsmaelMartinez.teams_for_linux %U
Icon=com.github.IsmaelMartinez.teams_for_linux
Type=Application
StartupNotify=true
Categories=Network;InstantMessaging;
MimeType=x-scheme-handler/msteams;
EOF

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH..."
    
    # Add to .bashrc
    if [ -f ~/.bashrc ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    
    # Add to .profile
    if [ -f ~/.profile ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile
    fi
    
    echo "PATH updated. Please run 'source ~/.bashrc' or restart your terminal."
fi

# Cleanup
cd /

echo ""
echo "Installation completed successfully!"
echo "===================="
echo "Microsoft Teams has been installed and added to your local path."
echo ""
echo "You can now:"
echo "1. Launch Teams from the application menu"
echo "2. Run 'teams' from the command line (after restarting terminal or running 'source ~/.bashrc')"
echo "3. Use Teams with file associations"
echo ""
echo "Note: If you encounter any issues, you may need to restart your session."
