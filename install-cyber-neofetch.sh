#!/bin/bash

# 🎯 Ultimate Cyber Range Neofetch Configuration Installer
# This script automatically sets up the comprehensive neofetch configuration
# designed for cyber security professionals, penetration testers, and developers.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${PURPLE}"
echo "🎯 ========================================== 🎯"
echo "   ULTIMATE CYBER RANGE NEOFETCH INSTALLER   "
echo "🎯 ========================================== 🎯"
echo -e "${NC}"

# Function to print status messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This configuration is optimized for macOS. Proceeding anyway..."
fi

# Check if Homebrew is installed
print_status "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew first..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed successfully!"
else
    print_success "Homebrew found!"
fi

# Install neofetch if not already installed
print_status "Checking for neofetch..."
if ! command -v neofetch &> /dev/null; then
    print_status "Installing neofetch..."
    brew install neofetch
    print_success "Neofetch installed successfully!"
else
    print_success "Neofetch is already installed!"
fi

# Create neofetch config directory if it doesn't exist
print_status "Setting up neofetch configuration directory..."
mkdir -p ~/.config/neofetch

# Backup existing configuration if it exists
if [ -f ~/.config/neofetch/config.conf ]; then
    print_status "Backing up existing neofetch configuration..."
    cp ~/.config/neofetch/config.conf ~/.config/neofetch/config.conf.backup.$(date +%Y%m%d_%H%M%S)
    print_success "Existing configuration backed up!"
fi

# Check if the cyber range config file exists in current directory
CYBER_CONFIG_FILE="./config.conf"
if [ ! -f "$CYBER_CONFIG_FILE" ]; then
    print_error "Cyber range neofetch configuration file not found!"
    print_error "Please ensure 'config.conf' is in the current directory."
    print_error "You can download it from: https://github.com/joseguzman1337/offensive-security/tree/macos-environment"
    exit 1
fi

# Apply the cyber range configuration
print_status "Applying ultimate cyber range neofetch configuration..."
cp "$CYBER_CONFIG_FILE" ~/.config/neofetch/config.conf
print_success "Configuration applied successfully!"

# Test the configuration
print_status "Testing the new configuration..."
echo -e "${CYAN}"
echo "🔥 ============================================ 🔥"
echo "     CYBER RANGE NEOFETCH CONFIGURATION       "
echo "🔥 ============================================ 🔥"
echo -e "${NC}"

# Run neofetch with the new configuration
neofetch

echo -e "${GREEN}"
echo "🎯 ========================================== 🎯"
echo "   INSTALLATION COMPLETED SUCCESSFULLY!      "
echo "🎯 ========================================== 🎯"
echo -e "${NC}"

print_success "Ultimate cyber range neofetch configuration is now active!"
print_status "Features enabled:"
echo -e "  ${GREEN}✅${NC} 31+ development and security tools displayed"
echo -e "  ${GREEN}✅${NC} Real-time system metrics (load, disk, battery, network)"
echo -e "  ${GREEN}✅${NC} Intelligent tool grouping and detection"
echo -e "  ${GREEN}✅${NC} Professional cyber security focused layout"
echo -e "  ${GREEN}✅${NC} Perfect for red team, blue team, and development work"

echo ""
print_status "To use: Simply run 'neofetch' in your terminal"
print_status "Your original config was backed up in ~/.config/neofetch/"

echo -e "${PURPLE}"
echo "🎯 Ready for your next cyber range mission! 🎯"
echo -e "${NC}"
