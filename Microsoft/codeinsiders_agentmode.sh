#!/bin/bash

# Install VS Code Insiders (if missing) and enable Copilot Agent Mode on macOS

# Function to install VS Code Insiders
install_vscode_insiders() {
    echo "⚙️ Installing VS Code Insiders..."
    # Download .zip from official Microsoft URL
    curl -L https://aka.ms/linux-arm64-deb -o ~/Downloads/vscode-insiders.zip
    
    # Extract and move to Applications
    unzip -q ~/Downloads/vscode-insiders.zip -d /Applications/
    
    # Add to PATH (for 'code-insiders' CLI)
    sudo ln -s "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code" /usr/local/bin/code-insiders
    
    echo "✅ VS Code Insiders installed to /Applications/"
}

# Function to enable Agent Mode
enable_agent_mode() {
    echo "⚙️ Enabling Copilot Agent Mode..."
    code-insiders --enable-features GitHubCopilotChatAgent
    code-insiders --update-config "chat.agent.enabled=true"
    code-insiders --update-config "github.copilot.chat.agent.autoFix=true"
    
    echo "✅ Copilot Agent Mode enabled!"
    echo "Restart VS Code Insiders to apply changes."
}

# Main execution
if ! command -v code-insiders &> /dev/null; then
    echo "VS Code Insiders not found!"
    read -p "Install VS Code Insiders now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_vscode_insiders
        enable_agent_mode
    else
        echo "❌ VS Code Insiders required for Agent Mode."
        exit 1
    fi
else
    enable_agent_mode
fi
