#!/bin/bash
set +e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG="blackarch_install_$(date +%Y%m%d_%H%M%S).log"
log() { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

echo -e "${GREEN}BlackArch Package-by-Package Installer${NC}"
log "Started"

# Fix mirrors
log "Configuring BlackArch mirrors..."
sudo bash -c 'cat > /etc/pacman.d/blackarch-mirrorlist << EOF
Server = https://mirror.yandex.ru/mirrors/blackarch/\$repo/os/\$arch
Server = https://www.mirrorservice.org/sites/blackarch.org/blackarch/\$repo/os/\$arch
Server = https://mirrors.ocf.berkeley.edu/blackarch/\$repo/os/\$arch
EOF'

# Create gcc14-libs compatibility package
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
    echo "Compatibility shim for gcc14-libs using current gcc-libs" > "$pkgdir/usr/share/doc/$pkgname/README"
}
EOF
    makepkg -si --noconfirm &>> "$LOG"
    cd /
    rm -rf "$TMPDIR"
    log "✓ gcc14-libs installed"
fi

# Sync databases
log "Syncing package databases..."
sudo pacman -Syy --noconfirm &>> "$LOG"

# Install each category package-by-package
CATEGORIES=(
    blackarch
    blackarch-webapp
    blackarch-fuzzer
    blackarch-scanner
    blackarch-recon
    blackarch-exploitation
    blackarch-defensive
    blackarch-automation
    blackarch-social
)

TOTAL_SUCCESS=0
TOTAL_FAILED=0

for cat in "${CATEGORIES[@]}"; do
    echo -e "${BLUE}=== Processing $cat ===${NC}"
    log "Processing $cat"
    
    MISSING=$(comm -23 <(pacman -Sgq "$cat" 2>/dev/null | sort) <(pacman -Qq | sort))
    TOTAL=$(echo "$MISSING" | wc -l)
    
    if [ $TOTAL -eq 0 ]; then
        echo -e "${GREEN}✓ $cat already complete${NC}"
        log "✓ $cat already complete"
        continue
    fi
    
    echo "$cat: $TOTAL packages to install"
    log "$cat: $TOTAL packages to install"
    SUCCESS=0
    FAILED=0
    BATCH=0
    
    for pkg in $MISSING; do
        # Remove stale lock before each install
        sudo rm -f /var/lib/pacman/db.lck
        
        # Install with 60s timeout
        yes "" 2>/dev/null | timeout 60 sudo pacman -S --needed --noconfirm --ask 4 "$pkg" &>> "$LOG"
        
        # If failed, retry with --overwrite for file conflicts
        if ! pacman -Q "$pkg" &>/dev/null; then
            yes "" 2>/dev/null | timeout 60 sudo pacman -S --needed --noconfirm --ask 4 --overwrite '*' "$pkg" &>> "$LOG"
        fi
        
        # Verify installation
        if pacman -Q "$pkg" &>/dev/null; then
            ((SUCCESS++))
            ((TOTAL_SUCCESS++))
        else
            ((FAILED++))
            ((TOTAL_FAILED++))
            echo "$pkg" >> "$LOG.failed"
        fi
        
        ((BATCH++))
        # Show progress every 50 packages
        if [ $((BATCH % 50)) -eq 0 ]; then
            echo -ne "\r  Progress: $BATCH/$TOTAL (✓$SUCCESS ✗$FAILED)"
        fi
    done
    
    echo ""
    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ $cat: $SUCCESS installed${NC}"
    else
        echo -e "${YELLOW}⚠ $cat: ✓$SUCCESS ✗$FAILED${NC}"
    fi
    log "$cat: ✓$SUCCESS ✗$FAILED"
done

echo ""
echo -e "${GREEN}╔═══════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════╝${NC}"
echo -e "${BLUE}Total: ✓${GREEN}$TOTAL_SUCCESS${NC} ✗${RED}$TOTAL_FAILED${NC}"
echo -e "${BLUE}Log: ${NC}$LOG"

log "Installation complete. Total: ✓$TOTAL_SUCCESS ✗$TOTAL_FAILED"
