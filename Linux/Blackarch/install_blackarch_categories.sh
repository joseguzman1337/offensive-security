#!/bin/bash

# Exit on error, but allow continue on individual package failures
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     BlackArch Auto-Installation Script (Enhanced)        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}This script will automatically:${NC}"
echo "  • Install required system dependencies"
echo "  • Resolve package conflicts"
echo "  • Install all BlackArch tool categories"
echo "  • Handle all prompts automatically"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 1: Install required dependencies first
echo -e "${YELLOW}[1/5] Installing required system dependencies...${NC}"

# Install Java runtime (needed by many tools)
if ! pacman -Q jre17-openjdk &>/dev/null; then
    echo "Installing Java Runtime (jre17-openjdk)..."
    sudo pacman -S --needed --noconfirm jre17-openjdk 2>/dev/null || true
fi

# Install Rust/Cargo (needed by many tools)
if ! pacman -Q rust &>/dev/null; then
    echo "Installing Rust/Cargo..."
    sudo pacman -S --needed --noconfirm rust 2>/dev/null || true
fi

# Install tesseract English data (most common)
if ! pacman -Q tesseract-data-eng &>/dev/null; then
    echo "Installing Tesseract OCR data (English)..."
    sudo pacman -S --needed --noconfirm tesseract-data-eng 2>/dev/null || true
fi

# Install plasma-framework (required by calamares)
echo "Installing plasma-framework (required by calamares)..."
sudo pacman -S --needed --noconfirm plasma-framework 2>/dev/null || echo "Note: plasma-framework unavailable, will skip calamares-dependent packages"

# Step 2: Handle package conflicts
echo -e "${YELLOW}[2/5] Resolving package conflicts...${NC}"

# Remove conflicting Python YARA package
if pacman -Q python-yara &>/dev/null; then
    echo "Removing python-yara (conflicts with python-yara-python-dex)..."
    sudo pacman -Rdd --noconfirm python-yara 2>/dev/null || true
fi

# Remove conflicting arsenic package
if pacman -Q python-arsenic &>/dev/null; then
    echo "Removing python-arsenic (conflicts with python-wapiti-arsenic)..."
    sudo pacman -Rdd --noconfirm python-arsenic 2>/dev/null || true
fi

# Step 3: Sync and update package database
echo -e "${YELLOW}[3/5] Updating package database...${NC}"
sudo pacman -Sy --noconfirm

# Step 4: Pre-install common problematic packages separately
echo -e "${YELLOW}[4/5] Pre-installing commonly required packages...${NC}"

# Install vagrant if needed (for malboxes)
if ! pacman -Q vagrant &>/dev/null; then
    echo "Installing vagrant (required by malboxes)..."
    sudo pacman -S --needed --noconfirm vagrant 2>/dev/null || echo "Vagrant unavailable, will skip malboxes"
fi

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
)

# Packages to skip (problematic or unnecessary)
# Skip calamares and its config if plasma-framework is not available
if ! pacman -Q plasma-framework &>/dev/null; then
    IGNORE_PACKAGES="aws-extender-cli,calamares,blackarch-config-calamares,malboxes"
    echo "Note: Skipping calamares (plasma-framework not available)"
else
    IGNORE_PACKAGES="aws-extender-cli"
fi

# Step 5: Install BlackArch categories
echo -e "${YELLOW}[5/5] Installing BlackArch categories...${NC}"
echo "This will take a while. Total categories: ${#categories[@]}"
echo -e "${BLUE}Tip: You can monitor progress in real-time${NC}"
echo ""

# Track statistics
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

for i in "${!categories[@]}"; do
  category="${categories[$i]}"
  current=$((i + 1))
  total=${#categories[@]}
  
  echo -e "${GREEN}┌─ [$current/$total] Installing: $category${NC}"
  
  # Check if category exists
  if ! pacman -Sg "$category" &>/dev/null; then
    echo -e "${RED}└─ Category does not exist, skipping...${NC}"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    echo ""
    continue
  fi
  
  # Use yes to auto-answer all prompts with default (1 for providers, y for skip)
  # Redirect stderr and filter output to reduce noise
  yes "" 2>/dev/null | sudo pacman -S \
    --needed \
    --noconfirm \
    --disable-download-timeout \
    --ignore "$IGNORE_PACKAGES" \
    --overwrite '*' \
    --ask 4 \
    "$category" &>/dev/null
  
  EXIT_CODE=$?
  
  if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}└─ ✓ Success${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    echo -e "${YELLOW}└─ ⚠ Completed with warnings (some packages may have been skipped)${NC}"
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
  
  echo ""
done

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              Installation Complete!                        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Installation Statistics:${NC}"
echo "  ✓ Successful:      $SUCCESS_COUNT categories"
echo "  ⚠ With warnings:   $FAILED_COUNT categories"
echo "  ⊗ Skipped:         $SKIPPED_COUNT categories"
echo ""
echo -e "${YELLOW}Notes:${NC}"
echo "  • Some packages may have been skipped due to dependency conflicts"
echo "  • To install specific tools: sudo pacman -S <tool-name>"
echo "  • To list available tools: pacman -Sg | grep blackarch"
echo "  • To search for tools: pacman -Ss blackarch-<category>"
echo ""
echo -e "${GREEN}Happy hacking! 🎯${NC}"
