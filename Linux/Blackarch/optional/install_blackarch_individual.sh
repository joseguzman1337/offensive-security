#!/bin/bash

set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="blackarch_install_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

echo -e "${GREEN}BlackArch Individual Package Installer${NC}"
log "Script started"

# Setup
sudo pacman-key --init &>/dev/null
sudo pacman-key --populate archlinux blackarch &>/dev/null
sudo pacman -Syy --noconfirm &>/dev/null

# Create gcc14-libs shim
if ! pacman -Q gcc14-libs &>/dev/null; then
    log "Creating gcc14-libs compatibility package..."
    TMPDIR=$(mktemp -d)
    cd "$TMPDIR"
    
    cat > PKGBUILD << 'EOF'
pkgname=gcc14-libs
pkgver=14.0.0
pkgrel=1
pkgdesc="GCC 14 compatibility shim"
arch=('x86_64')
depends=('gcc-libs')
provides=('gcc14-libs')

package() {
    mkdir -p "$pkgdir/usr/share/doc/$pkgname"
    echo "Compatibility shim" > "$pkgdir/usr/share/doc/$pkgname/README"
}
EOF
    
    makepkg -si --noconfirm &>> "$LOG_FILE"
    cd /
    rm -rf "$TMPDIR"
    log "✓ gcc14-libs installed"
fi

categories=(
blackarch
blackarch-webapp
blackarch-fuzzer
blackarch-scanner
blackarch-proxy
blackarch-windows
blackarch-dos
blackarch-disassembler
blackarch-sniffer
blackarch-voip
blackarch-fingerprint
blackarch-networking
blackarch-recon
blackarch-cracker
blackarch-exploitation
blackarch-spoof
blackarch-forensic
blackarch-crypto
blackarch-backdoor
blackarch-defensive
blackarch-wireless
blackarch-automation
blackarch-radio
blackarch-binary
blackarch-packer
blackarch-reversing
blackarch-mobile
blackarch-malware
blackarch-code-audit
blackarch-social
blackarch-honeypot
blackarch-misc
blackarch-wordlist
blackarch-decompiler
blackarch-config
blackarch-debugger
blackarch-bluetooth
blackarch-database
blackarch-automobile
blackarch-hardware
blackarch-nfc
blackarch-tunnel
blackarch-drone
blackarch-unpacker
blackarch-firmware
blackarch-keylogger
blackarch-stego
blackarch-anti-forensic
blackarch-ids
blackarch-threat-model
blackarch-gpu
)

SUCCESS=0
FAILED=0

for i in "${!categories[@]}"; do
    cat="${categories[$i]}"
    echo -e "${BLUE}[$((i+1))/${#categories[@]}] $cat${NC}"
    
    # Get all packages in category
    pkgs=($(pacman -Sgq "$cat" 2>/dev/null))
    
    if [ ${#pkgs[@]} -eq 0 ]; then
        echo -e "${RED}✗ Category not found${NC}"
        continue
    fi
    
    installed=0
    failed=0
    
    for pkg in "${pkgs[@]}"; do
        # Skip known broken packages
        case "$pkg" in
            aws-extender-cli|calamares|blackarch-config-calamares)
                continue
                ;;
        esac
        
        # Check if already installed
        if pacman -Q "$pkg" &>/dev/null; then
            ((installed++))
            continue
        fi
        
        # Install with auto-yes to all prompts
        yes "" 2>/dev/null | sudo pacman -S --needed --noconfirm --ask 4 "$pkg" &>> "$LOG_FILE"
        
        if [ $? -eq 0 ]; then
            ((installed++))
        else
            ((failed++))
            echo "$pkg" >> "$LOG_FILE.failed"
        fi
    done
    
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}✓ $installed packages${NC}"
        ((SUCCESS++))
    else
        echo -e "${YELLOW}⚠ $installed ok, $failed failed${NC}"
        ((FAILED++))
    fi
done

echo ""
echo -e "${GREEN}╔═══════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!     ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════╝${NC}"
echo -e "${BLUE}✓ Success: ${GREEN}$SUCCESS${NC} categories"
echo -e "${BLUE}✗ Failed:  ${RED}$FAILED${NC} categories"
echo -e "${CYAN}Log: $LOG_FILE${NC}"

log "Completed. Success: $SUCCESS, Failed: $FAILED"
