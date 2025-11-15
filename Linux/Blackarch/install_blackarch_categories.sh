#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== BlackArch Installation Script ===${NC}"
echo "This script will automatically install BlackArch tools and handle dependencies."
echo ""

# Step 1: Install required dependencies first
echo -e "${YELLOW}[1/4] Installing required dependencies...${NC}"
echo "Installing plasma-framework (required by calamares)..."
sudo pacman -S --needed --noconfirm plasma-framework 2>/dev/null || echo "Note: plasma-framework may already be installed or unavailable"

# Step 2: Handle Python YARA conflict
echo -e "${YELLOW}[2/4] Resolving Python package conflicts...${NC}"
if pacman -Q python-yara &>/dev/null && pacman -Q python-yara-python-dex &>/dev/null; then
    echo "Removing python-yara to avoid conflict with python-yara-python-dex..."
    sudo pacman -Rdd --noconfirm python-yara 2>/dev/null || true
fi

# Step 3: Sync and update package database
echo -e "${YELLOW}[3/4] Updating package database...${NC}"
sudo pacman -Sy --noconfirm

# List of BlackArch categories to install
categories=(
  blackarch
  blackarch-webapp
  blackarch-fuzzer
  blackarch-scanner
  blackarch-proxy
  blackarch-windows
  blackarch-dos
  blackarch-disassembler
  blackarch-cracker
  blackarch-voip
  blackarch-exploitation
  blackarch-recon
  blackarch-spoof
  blackarch-forensic
  blackarch-crypto
  blackarch-backdoor
  blackarch-networking
  blackarch-misc
  blackarch-defensive
  blackarch-wireless
  blackarch-automation
  blackarch-sniffer
  blackarch-binary
  blackarch-packer
  blackarch-reversing
  blackarch-mobile
  blackarch-malware
  blackarch-code-audit
  blackarch-social
  blackarch-honeypot
  blackarch-hardware
  blackarch-fingerprint
  blackarch-decompiler
  blackarch-config
  blackarch-debugger
  blackarch-firmware
  blackarch-bluetooth
  blackarch-database
  blackarch-automobile
  blackarch-nfc
  blackarch-tunnel
  blackarch-drone
  blackarch-unpacker
  blackarch-radio
  blackarch-keylogger
  blackarch-stego
  blackarch-anti-forensic
  blackarch-ids
  blackarch-gpu
  fwupd
)

# Packages to skip (problematic or unnecessary)
IGNORE_PACKAGES="aws-extender-cli,malboxes"

# Step 4: Install BlackArch categories
echo -e "${YELLOW}[4/4] Installing BlackArch categories...${NC}"
echo "This will take a while. Total categories: ${#categories[@]}"
echo ""

for i in "${!categories[@]}"; do
  category="${categories[$i]}"
  current=$((i + 1))
  total=${#categories[@]}
  
  echo -e "${GREEN}[$current/$total] Installing category: $category${NC}"
  
  # Use printf and yes to auto-answer prompts
  # --noconfirm: Skip confirmations
  # --needed: Skip already installed packages
  # --ignore: Skip problematic packages
  # --overwrite '*': Allow file overwrites
  # Answer "1" (default) for provider choices, "y" to skip unresolvable packages
  printf '1\n1\n1\ny\n' | sudo pacman -S \
    --needed \
    --noconfirm \
    --disable-download-timeout \
    --ignore "$IGNORE_PACKAGES" \
    --overwrite '*' \
    "$category" 2>&1 | grep -v "^::" | grep -v "warning:" || true
  
  echo ""
done

echo -e "${GREEN}=== Installation Complete ===${NC}"
echo "BlackArch tools have been installed."
echo ""
echo "Note: Some packages may have been skipped due to dependency conflicts."
echo "You can manually install specific tools using: sudo pacman -S <package-name>"
