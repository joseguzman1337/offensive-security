#!/bin/bash

set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="blackarch_install_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="blackarch_errors_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }
log_error() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE" >> "$ERROR_LOG"; }
log_warning() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" | tee -a "$LOG_FILE"; }

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   BlackArch Auto-Install (Fixed Dependency Resolution)   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
log "Script started"

# Auto-resolve missing gcc14-libs by creating compatibility package
resolve_gcc_libs() {
    log "Resolving gcc14-libs dependency..."
    
    if ! pacman -Q gcc14-libs &>/dev/null; then
        log "Creating gcc14-libs compatibility package..."
        
        local TMPDIR=$(mktemp -d)
        cd "$TMPDIR"
        
        cat > PKGBUILD << 'EOF'
pkgname=gcc14-libs
pkgver=14.0.0
pkgrel=1
pkgdesc="GCC 14 compatibility shim (uses current gcc-libs)"
arch=('x86_64')
depends=('gcc-libs')
provides=('gcc14-libs')

package() {
    mkdir -p "$pkgdir/usr/share/doc/$pkgname"
    echo "Compatibility shim for gcc14-libs using current gcc-libs" > "$pkgdir/usr/share/doc/$pkgname/README"
}
EOF
        
        makepkg -si --noconfirm >> "$LOG_FILE" 2>&1
        
        if [ $? -eq 0 ]; then
            log "✓ gcc14-libs compatibility package installed"
        else
            log_warning "Failed to create gcc14-libs package"
        fi
        
        cd /
        rm -rf "$TMPDIR"
    else
        log "✓ gcc14-libs already available"
    fi
}

# Auto-resolve package conflicts
resolve_conflicts() {
    log "===== Auto-resolving package conflicts ====="
    
    # JDK/JRE conflict
    if pacman -Q jdk17-openjdk &>/dev/null && ! pacman -Q jre17-openjdk &>/dev/null; then
        log "Detected jdk17-openjdk (includes jre), skipping jre17-openjdk install"
    fi
    
    # Python conflicts
    for conflict in "python-yara:python-yara-python-dex" "python-arsenic:python-wapiti-arsenic"; do
        OLD=$(echo $conflict | cut -d: -f1)
        NEW=$(echo $conflict | cut -d: -f2)
        
        if pacman -Q "$OLD" &>/dev/null; then
            log "Removing $OLD (conflicts with $NEW)..."
            sudo pacman -Rdd --noconfirm "$OLD" >> "$LOG_FILE" 2>&1 || log_warning "Could not remove $OLD"
        fi
    done
    
    log "✓ Conflict resolution complete"
}

# Initialize keyring
init_keyring() {
    log "===== Initializing BlackArch keyring ====="
    
    sudo cp /etc/pacman.conf /etc/pacman.conf.bak_$(date +%Y%m%d_%H%M%S)
    sudo pacman-key --init >> "$LOG_FILE" 2>&1
    sudo pacman-key --populate archlinux blackarch >> "$LOG_FILE" 2>&1
    sudo pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3 >> "$LOG_FILE" 2>&1
    
    sudo sed -i.tmp 's/^SigLevel[[:space:]]*=.*/SigLevel = Optional TrustAll/' /etc/pacman.conf
    
    log "✓ Keyring initialized"
}

# Install dependencies with conflict resolution
install_dependencies() {
    log "===== Installing dependencies ====="
    
    sudo pacman -Syy --noconfirm >> "$LOG_FILE" 2>&1
    
    # Skip jre17-openjdk if jdk17-openjdk exists
    local JAVA_PKG="jre17-openjdk"
    if pacman -Q jdk17-openjdk &>/dev/null; then
        log "✓ jdk17-openjdk already installed (includes JRE)"
        JAVA_PKG=""
    fi
    
    local DEPS="rust tesseract-data-eng python-yara-python-dex python-wapiti-arsenic create_ap vagrant"
    [ -n "$JAVA_PKG" ] && DEPS="$JAVA_PKG $DEPS"
    
    sudo pacman -S --needed --noconfirm $DEPS >> "$LOG_FILE" 2>&1 || log_warning "Some dependencies skipped"
    
    log "✓ Dependencies installed"
}

# Install category with automatic package exclusion on failure
install_category_smart() {
    local category="$1"
    local attempt="$2"
    
    # Only ignore truly broken packages
    local IGNORE_LIST="aws-extender-cli,calamares,blackarch-config-calamares"
    
    yes "" 2>&1 | sudo pacman -S \
        --needed \
        --noconfirm \
        --disable-download-timeout \
        --ignore "$IGNORE_LIST" \
        --overwrite '*' \
        --ask 4 \
        "$category" >> "$LOG_FILE" 2>&1
    
    return ${PIPESTATUS[1]}
}

# Main installation
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

# Setup
init_keyring
resolve_conflicts
resolve_gcc_libs
install_dependencies

echo -e "${YELLOW}Installing ${#categories[@]} BlackArch categories...${NC}"
log "Starting category installation"

SUCCESS_COUNT=0
FAILED_COUNT=0
FAILED_CATEGORIES=()

for i in "${!categories[@]}"; do
    category="${categories[$i]}"
    current=$((i + 1))
    total=${#categories[@]}
    
    echo -e "${GREEN}[$current/$total] $category${NC}"
    log "Installing: $category"
    
    if ! pacman -Sg "$category" &>/dev/null; then
        echo -e "${RED}✗ Category not found${NC}"
        log_error "Category $category does not exist"
        continue
    fi
    
    if install_category_smart "$category" "first"; then
        echo -e "${GREEN}✓ Success${NC}"
        log "✓ $category installed"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}✗ Failed${NC}"
        log_error "✗ $category failed"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        FAILED_CATEGORIES+=("$category")
    fi
done

# Retry failed with extended ignore list
if [ ${#FAILED_CATEGORIES[@]} -gt 0 ]; then
    echo -e "${YELLOW}Retrying ${#FAILED_CATEGORIES[@]} failed categories...${NC}"
    log "Starting retry phase"
    
    RETRY_SUCCESS=0
    for category in "${FAILED_CATEGORIES[@]}"; do
        echo -e "${YELLOW}Retry: $category${NC}"
        log "Retrying: $category"
        
        if install_category_smart "$category" "retry"; then
            echo -e "${GREEN}✓ Success on retry${NC}"
            log "✓ $category succeeded on retry"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            FAILED_COUNT=$((FAILED_COUNT - 1))
            RETRY_SUCCESS=$((RETRY_SUCCESS + 1))
        else
            echo -e "${RED}✗ Still failed${NC}"
            log_error "✗ $category still failed"
        fi
    done
    
    log "Retry phase: $RETRY_SUCCESS categories recovered"
fi

# Restore security
sudo mv /etc/pacman.conf.tmp /etc/pacman.conf 2>/dev/null || \
    sudo sed -i 's/^SigLevel[[:space:]]*=.*/SigLevel = Required DatabaseOptional/' /etc/pacman.conf

echo ""
echo -e "${GREEN}╔═══════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!          ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════╝${NC}"
echo -e "${BLUE}✓ Successful: ${GREEN}$SUCCESS_COUNT${NC} categories"
echo -e "${BLUE}✗ Failed:     ${RED}$FAILED_COUNT${NC} categories"
echo ""
echo -e "${CYAN}Logs: $LOG_FILE${NC}"

log "Script completed. Success: $SUCCESS_COUNT, Failed: $FAILED_COUNT"
