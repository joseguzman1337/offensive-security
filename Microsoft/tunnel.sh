#!/bin/bash

# VS Code Insiders Tunnel Service Setup Script for RHEL 9.5
# This creates a persistent user service that auto-restarts

SERVICE_NAME="code-insiders-tunnel.service"
SERVICE_FILE="$HOME/.config/systemd/user/${SERVICE_NAME}"
VSCODE_BIN="/usr/bin/code-insiders"

# Ensure user lingering is enabled for persistent user services
sudo loginctl enable-linger $(whoami)

# Create the systemd service file
mkdir -p ~/.config/systemd/user
cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=VS Code Insiders Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=${VSCODE_BIN} tunnel --verbose
Restart=always
RestartSec=5
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
Environment="VSCODE_CLI_DATA_DIR=${HOME}/.vscode-insiders"

# Optional: If you need to login first, uncomment and modify:
# ExecStartPre=${VSCODE_BIN} tunnel user login --provider github

StandardOutput=journal
StandardError=journal
SyslogIdentifier=code-tunnel

[Install]
WantedBy=default.target
EOF

# Reload systemd and enable the service
systemctl --user daemon-reload
systemctl --user enable --now ${SERVICE_NAME}

# Verify the service is running
echo "Service status:"
systemctl --user status ${SERVICE_NAME}

# Create a script to check logs
cat > ~/check-code-tunnel-logs.sh <<'EOF'
#!/bin/bash
journalctl --user -u code-insiders-tunnel.service -f
EOF
chmod +x ~/check-code-tunnel-logs.sh

echo -e "\nSetup complete!"
echo -e "To check logs: ~/check-code-tunnel-logs.sh"
echo -e "To stop service: systemctl --user stop ${SERVICE_NAME}"
echo -e "To start service: systemctl --user start ${SERVICE_NAME}"
