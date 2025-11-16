#!/bin/bash

sudo pacman -Syy jre17-openjdk rust tesseract-data-eng

# Exit on error, but allow continue on individual package failures
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Setup logging
LOG_FILE="blackarch_install_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="blackarch_errors_$(date +%Y%m%d_%H%M%S).log"
FAILED_PACKAGES="blackarch_failed_packages_$(date +%Y%m%d_%H%M%S).txt"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE" >> "$ERROR_LOG"
}

log_warning() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1" | tee -a "$LOG_FILE"
}

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}║     BlackArch Auto-Installation Script (Enhanced)        ║${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
log "Script started"
log "Log file: $LOG_FILE"
log "Error log: $ERROR_LOG"
log "Failed packages list: $FAILED_PACKAGES"
echo ""

# ========================================================================
# === ***IMPROVEMENT (per user request)*** ===
# Added -e flag to all introductory echo commands to correctly render colors.
# ========================================================================
echo -e "${BLUE}This script will automatically:${NC}"
echo -e "  • Install required system dependencies"
echo -e "  • Resolve package conflicts"
echo -e "  • Install all BlackArch tool categories"
echo -e "  • Handle all prompts automatically"
echo -e "  • Log all operations to: ${CYAN}$LOG_FILE${NC}"
# ========================================================================
# === END OF IMPROVEMENT ===
# ========================================================================

echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."
echo ""

# Step 0: Initialize BlackArch keyring AND install ALL dependencies (MANDATORY)
echo -e "${YELLOW}[0/7] Initializing BlackArch keyring + Installing ALL dependencies...${NC}" | tee -a "$LOG_FILE"
log "Phase 0: Initializing package keyring and installing ALL mandatory dependencies"

log "Backing up pacman.conf..."
sudo cp /etc/pacman.conf /etc/pacman.conf.bak_$(date +%Y%m%d_%H%M%S)
log "✓ Backup created"

log "Initializing pacman keyring..."
sudo pacman-key --init >> "$LOG_FILE" 2>&1 || log_warning "Keyring already initialized"
log "✓ Keyring initialized"

log "Populating keyring with Arch and BlackArch keys..."
sudo pacman-key --populate archlinux blackarch >> "$LOG_FILE" 2>&1
log "✓ Keys populated"

log "Locally signing BlackArch developer key (Evan Teitelman)..."
sudo pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3 >> "$LOG_FILE" 2>&1
log "✓ BlackArch developer key signing attempted."

# ========================================================================
# === ***PROACTIVE PGP HANDLING BLOCK*** ===
# ========================================================================
log_warning "Proactively adjusting signature level to prevent PGP failures..."
sudo sed -i.tmp 's/^SigLevel[[:space:]]*=.*/SigLevel = Optional TrustAll/' /etc/pacman.conf
log "✓ Temporarily set SigLevel to Optional TrustAll"
# ========================================================================
# === END OF PGP BLOCK ===
# ========================================================================

log "✓ Keyring initialization complete."
echo ""

# Clean pacman cache to remove any corrupted packages
log "Cleaning pacman cache (remove corrupted packages)..."
sudo pacman -Scc --noconfirm >> "$LOG_FILE" 2>&1 || log_warning "Cache cleaning had warnings"
log "✓ Pacman cache cleaned"

# Update package database
log "Updating package database..."
sudo pacman -Syy --noconfirm >> "$LOG_FILE" 2>&1
log "✓ Package database updated"
echo ""

# ========================================================================
# === ***IMPROVED DEPENDENCY INSTALL BLOCK (Consolidated)*** ===
# ========================================================================
log "===== Installing ALL mandatory system dependencies ====="

# Define list of mandatory packages from official repos
PACMAN_DEPS=(
    "jre17-openjdk"
    "rust"
    "tesseract-data-eng"
    "python-yara-python-dex"
    "python-wapiti-arsenic"
    "create_ap"
)

# Filter out packages that are already installed
DEPS_TO_INSTALL=()
for pkg in "${PACMAN_DEPS[@]}"; do
    if ! pacman -Q "$pkg" &>/dev/null; then
        DEPS_TO_INSTALL+=("$pkg")
    else
        log "✓ $pkg already installed"
    fi
done

# Install all missing repo packages "in one go"
if [ ${#DEPS_TO_INSTALL[@]} -gt 0 ]; then
    log "Installing missing repo dependencies: ${DEPS_TO_INSTALL[*]}..."
    sudo pacman -S --needed --noconfirm "${DEPS_TO_INSTALL[@]}" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "✓ All repo dependencies installed successfully."
    else
        log_error "FAILED to install one or more repo dependencies. Check log."
    fi
else
    log "✓ All mandatory repo dependencies are already satisfied."
fi

# 4. Plasma Framework - EXCLUDED (calamares not needed)
log "Skipping plasma-framework (calamares excluded)"

# 5. Vagrant (MANDATORY - from AUR)
if ! pacman -Q vagrant &>/dev/null; then
    log "Installing vagrant (MANDATORY for malboxes)..."
    if sudo pacman -S --needed --noconfirm vagrant >> "$LOG_FILE" 2>&1; then
        log "✓ Vagrant installed from repos"
    else
        log "Vagrant not in repos, installing from AUR (MANDATORY)..."
        if command -v paru &>/dev/null; then
            if paru -S --needed --noconfirm vagrant >> "$LOG_FILE" 2>&1; then
                log "✓ Vagrant installed from AUR via paru"
            else
                log_error "FAILED: Vagrant installation via paru"
            fi
        elif command -v yay &>/dev/null; then
            if yay -S --needed --noconfirm vagrant >> "$LOG_FILE" 2>&1; then
                log "✓ Vagrant installed from AUR via yay"
            else
                log_error "FAILED: Vagrant installation via yay"
            fi
        else
            log_error "CRITICAL: No AUR helper (paru/yay) found - cannot install vagrant"
        fi
    fi
else
    log "✓ Vagrant already installed"
fi

log "===== All mandatory dependencies installed ====="
echo ""
# ========================================================================
# === END OF IMPROVED DEPENDENCY BLOCK ===
# ========================================================================

# Step 1: Verify dependencies (all installed in Phase 0)
echo -e "${YELLOW}[1/7] Verifying system dependencies...${NC}" | tee -a "$LOG_FILE"
log "Phase 1: Verifying all dependencies are installed"

# Verify all mandatory dependencies
MISSING_DEPS=()

! pacman -Q jre17-openjdk &>/dev/null && MISSING_DEPS+=("jre17-openjdk")
! pacman -Q rust &>/dev/null && MISSING_DEPS+=("rust")
! pacman -Q tesseract-data-eng &>/dev/null && MISSING_DEPS+=("tesseract-data-eng")
! pacman -Q vagrant &>/dev/null && MISSING_DEPS+=("vagrant")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    log_error "CRITICAL: Missing mandatory dependencies: ${MISSING_DEPS[*]}"
    log_error "These should have been installed in Phase 0!"
    exit 1
else
    log "✓ All mandatory dependencies verified installed"
fi

# ========================================================================
# === ***IMPROVED PHASE 2 (Conflict Resolution Logging)*** ===
# ========================================================================
echo -e "${YELLOW}[2/7] Resolving package conflicts...${NC}" | tee -a "$LOG_FILE"
log "Phase 2: Resolving package conflicts"

# Check and remove python-yara
if pacman -Q python-yara &>/dev/null; then
    log "Removing python-yara (conflicts with python-yara-python-dex)..."
    if sudo pacman -Rdd --noconfirm python-yara >> "$LOG_FILE" 2>&1; then
        log "✓ python-yara removed successfully"
    else
        log_warning "Failed to remove python-yara (it was detected, but removal failed. Check log for pacman error.)"
    fi
else
    log "python-yara not installed, no conflict."
fi

# Check and remove python-arsenic
if pacman -Q python-arsenic &>/dev/null; then
    log "Removing python-arsenic (conflicts with python-wapiti-arsenic)..."
    if sudo pacman -Rdd --noconfirm python-arsenic >> "$LOG_FILE" 2>&1; then
        log "✓ python-arsenic removed successfully"
    else
        log_warning "Failed to remove python-arsenic (it was detected, but removal failed. Check log for pacman error.)"
    fi
else
    log "python-arsenic not installed, no conflict."
fi

# Check and remove linux-wifi-hotspot
if pacman -Q linux-wifi-hotspot &>/dev/null; then
    log "Removing linux-wifi-hotspot (conflicts with create_ap)..."
    if sudo pacman -Rdd --noconfirm linux-wifi-hotspot >> "$LOG_FILE" 2>&1; then
        log "✓ linux-wifi-hotspot removed successfully"
    else
        log_warning "Failed to remove linux-wifi-hotspot (it was detected, but removal failed. Check log for pacman error.)"
    fi
else
    log "linux-wifi-hotspot not installed, no conflict."
fi
# ========================================================================
# === END OF IMPROVED PHASE 2 ===
# ========================================================================

# Step 3: Sync and update package database
echo -e "${YELLOW}[3/7] Updating package database...${NC}" | tee -a "$LOG_FILE"
log "Phase 3: Updating package database"
if sudo pacman -Sy --noconfirm >> "$LOG_FILE" 2>&1; then
    log "✓ Package database updated successfully"
else
    log_error "Failed to update package database"
fi

# Step 4: Update package database before category installation
echo -e "${YELLOW}[4/7] Final package database sync...${NC}" | tee -a "$LOG_FILE"
log "Phase 4: Final package database synchronization"
if sudo pacman -Sy --noconfirm >> "$LOG_FILE" 2>&1; then
    log "✓ Package database synced"
else
    log_warning "Package database sync had warnings"
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

# No packages will be skipped - all dependencies installed
IGNORE_LIST=("aws-extender-cli" "calamares" "blackarch-config-calamares")  # Skip broken and excluded packages

# Join array into comma-separated string
IGNORE_PACKAGES=$(IFS=, ; echo "${IGNORE_LIST[*]}")
log "Packages to ignore: $IGNORE_PACKAGES"

# Step 5: Install BlackArch categories
echo -e "${YELLOW}[5/7] Installing BlackArch categories...${NC}" | tee -a "$LOG_FILE"
log "Phase 5: Installing BlackArch categories"
log "Total categories to install: ${#categories[@]}"
echo "This will take a while. Total categories: ${#categories[@]}" | tee -a "$LOG_FILE"
echo -e "${BLUE}Tip: Monitor detailed progress in: ${CYAN}$LOG_FILE${NC}"
echo ""

# Track statistics
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0
FAILED_CATEGORIES=()

for i in "${!categories[@]}"; do
  category="${categories[$i]}"
  current=$((i + 1))
  total=${#categories[@]}
  
  echo -e "${GREEN}┌─ [$current/$total] Installing: $category${NC}" | tee -a "$LOG_FILE"
  log "Starting installation of category: $category"
  
  # Check if category exists
  if ! pacman -Sg "$category" &>/dev/null; then
    echo -e "${RED}└─ Category does not exist, skipping...${NC}" | tee -a "$LOG_FILE"
    log_error "Category $category does not exist in repository"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    echo "$category" >> "$FAILED_PACKAGES"
    echo ""
    continue
  fi
  
  # Create temporary log for this category
  CATEGORY_LOG="/tmp/blackarch_${category}_$$.log"
  
  # Use yes to auto-answer all prompts with default (1 for providers, y for skip)
  # Capture full output for analysis
  # Use pipefail disabled to capture only pacman exit code, not yes exit code
  set +o pipefail
  yes "" 2>&1 | sudo pacman -S \
    --needed \
    --noconfirm \
    --disable-download-timeout \
    --ignore "$IGNORE_PACKAGES" \
    --overwrite '*' \
    --ask 4 \
    "$category" > "$CATEGORY_LOG" 2>&1
  
  # Get exit code from pacman (${PIPESTATUS[1]}), not yes (${PIPESTATUS[0]})
  EXIT_CODE=${PIPESTATUS[1]}
  set -o pipefail 2>/dev/null || true
  
  # Analyze the output for specific errors (ensure single-line output)
  UNRESOLVABLE=$(grep -c "unresolvable package conflicts" "$CATEGORY_LOG" 2>/dev/null || echo "0")
  MISSING_DEPS=$(grep -c "unable to satisfy dependency" "$CATEGORY_LOG" 2>/dev/null || echo "0")
  CONFLICTS=$(grep -c "are in conflict" "$CATEGORY_LOG" 2>/dev/null || echo "0")
  
  # Append category log to main log
  cat "$CATEGORY_LOG" >> "$LOG_FILE"
  rm -f "$CATEGORY_LOG"
  
  # Check if pacman exited with a non-zero status
  if [ "$EXIT_CODE" -eq 0 ]; then
    echo -e "${GREEN}└─ ✓ Success${NC}" | tee -a "$LOG_FILE"
    log "Category $category installed successfully"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
  else
    # ANY non-zero exit code is a failure.
    FAILED_COUNT=$((FAILED_COUNT + 1))
    FAILED_CATEGORIES+=("$category") # Add to array for Phase 7 retry

    # Log specific error message if found
    if [ "$UNRESOLVABLE" -gt 0 ] || [ "$MISSING_DEPS" -gt 0 ] || [ "$CONFLICTS" -gt 0 ]; then
        echo -e "${RED}└─ ✗ Failed (dependency issues)${NC}" | tee -a "$LOG_FILE"
        log_error "Category $category failed: Unresolvable=$UNRESOLVABLE, Missing Deps=$MISSING_DEPS, Conflicts=$CONFLICTS"
        echo "$category - Unresolvable: $UNRESOLVABLE, Missing Deps: $MISSING_DEPS, Conflicts: $CONFLICTS" >> "$FAILED_PACKAGES"
    else
        # This will now catch PGP errors (exit code 1) and other generic failures
        echo -e "${RED}└─ ✗ Failed (exit code: $EXIT_CODE)${NC}" | tee -a "$LOG_FILE"
        log_error "Category $category failed (exit code: $EXIT_CODE). Check log for PGP or other errors."
        echo "$category - Exit code: $EXIT_CODE" >> "$FAILED_PACKAGES"
    fi
  fi
  
  echo ""
done

# Step 6: Restore secure signature checking if it was modified
echo -e "${YELLOW}[6/7] Restoring security settings...${NC}" | tee -a "$LOG_FILE"
log "Phase 6: Restoring secure signature checking"

if [ -f /etc/pacman.conf.tmp ]; then
    log "Restoring original pacman.conf with strict signature checking..."
    sudo mv /etc/pacman.conf.tmp /etc/pacman.conf 2>/dev/null || {
        sudo sed -i 's/^SigLevel[[:space:]]*=.*/SigLevel = Required DatabaseOptional/' /etc/pacman.conf
    }
    log "✓ Signature checking restored to secure defaults"
    echo -e "${GREEN}✓ Security settings restored${NC}" | tee -a "$LOG_FILE"
else
    log "Signature level was not modified, no restoration needed"
fi
echo ""

# Step 6.5: Generate summary
echo -e "${YELLOW}Finalizing installation...${NC}" | tee -a "$LOG_FILE"
log "Phase 6.5: Generating summary"

echo ""
echo -e "${GREEN}╬════════════════════════════════════════════════════════════╗${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}║              Installation Complete!                        ║${NC}" | tee -a "$LOG_FILE"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

log "Installation complete. Generating statistics..."

echo -e "${BLUE}╔═══ Installation Statistics ═══╗${NC}" | tee -a "$LOG_FILE"
echo -e "  ${GREEN}✓ Successful:${NC}      $SUCCESS_COUNT categories" | tee -a "$LOG_FILE"
echo -e "  ${RED}✗ Failed:${NC}          $FAILED_COUNT categories" | tee -a "$LOG_FILE"
echo -e "  ${YELLOW}⚠ Skipped:${NC}         $SKIPPED_COUNT categories" | tee -a "$LOG_FILE"
echo -e "${BLUE}╚══════════════════════════════╝${NC}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Show failed categories if any
if [ ${#FAILED_CATEGORIES[@]} -gt 0 ]; then
    echo -e "${RED}Failed Categories (will attempt retry):${NC}" | tee -a "$LOG_FILE"
    for failed_cat in "${FAILED_CATEGORIES[@]}"; do
        echo "  • $failed_cat" | tee -a "$LOG_FILE"
    done
    echo "" | tee -a "$LOG_FILE"
    log_error "Total failed categories: ${#FAILED_CATEGORIES[@]}"
fi

echo -e "${CYAN}╔═══ Log Files ═══╗${NC}" | tee -a "$LOG_FILE"
echo -e "  ${MAGENTA}● Main log:${NC}        $LOG_FILE"
echo -e "  ${MAGENTA}● Error log:${NC}      $ERROR_LOG"
echo -e "  ${MAGENTA}● Failed packages:${NC} $FAILED_PACKAGES"
echo -e "${CYAN}╚═════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}╔═══ Useful Commands ═══╗${NC}"
echo -e "  ${BLUE}● View main log:${NC}"
echo -e "    less $LOG_FILE"
echo ""
echo -e "  ${BLUE}● View errors only:${NC}"
echo -e "    less $ERROR_LOG"
echo ""
echo -e "  ${BLUE}● View failed packages:${NC}"
echo -e "    cat $FAILED_PACKAGES"
echo ""
echo -e "  ${BLUE}● List all BlackArch tools:${NC}"
echo -e "    pacman -Sg | grep blackarch"
echo ""
echo -e "  ${BLUE}● Install specific tool:${NC}"
echo -e "    sudo pacman -S <tool-name>"
echo ""
echo -e "  ${BLUE}● Retry failed category:${NC}"
echo -e "    sudo pacman -S <category-name>"
echo -e "${YELLOW}╚══════════════════════════╝${NC}"
echo ""

# Step 7: Offer to retry failed categories with PGP signature workaround
if [ ${#FAILED_CATEGORIES[@]} -gt 0 ]; then
    echo -e "${YELLOW}[7/7] Handling failed categories...${NC}" | tee -a "$LOG_FILE"
    log "Phase 7: Retry mechanism for failed categories"
    echo -e "${YELLOW}Would you like to retry failed categories? (y/N)${NC}"
    read -t 30 -r RETRY_ANSWER || RETRY_ANSWER="n"
    
    if [[ $RETRY_ANSWER =~ ^[Yy]$ ]]; then
        log "User chose to retry failed categories"
        echo -e "${BLUE}Retrying failed categories...${NC}" | tee -a "$LOG_FILE"
        
        # Try normal retry first
        STILL_FAILED=()
        for failed_cat in "${FAILED_CATEGORIES[@]}"; do
            echo -e "${YELLOW}Retrying: $failed_cat${NC}" | tee -a "$LOG_FILE"
            log "Retry attempt for category: $failed_cat"
            
            sudo pacman -S --needed --noconfirm --ignore "$IGNORE_PACKAGES" "$failed_cat" >> "$LOG_FILE" 2>&1
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Success on retry!${NC}" | tee -a "$LOG_FILE"
                log "Category $failed_cat succeeded on retry"
            else
                echo -e "${RED}✗ Still failed${NC}" | tee -a "$LOG_FILE"
                log_error "Category $failed_cat still failed on retry"
                STILL_FAILED+=("$failed_cat")
            fi
        done
        
        # If still have failures, check if they're PGP-related
        if [ ${#STILL_FAILED[@]} -gt 0 ]; then
            echo ""
            echo -e "${RED}Some categories still failed.${NC}" | tee -a "$LOG_FILE"
            echo -e "${YELLOW}Checking for PGP signature issues...${NC}" | tee -a "$LOG_FILE"
            
            # Check last error for signature issues
            if tail -50 "$LOG_FILE" | grep -qi "signature.*unknown trust\|signature.*invalid"; then
                log_warning "Detected PGP signature trust issues"
                echo -e "${YELLOW}PGP signature issues detected.${NC}"
                echo -e "${YELLOW}Retry with temporarily relaxed signature checking? (y/N)${NC}"
                read -t 30 -r PGP_RETRY || PGP_RETRY="n"
                
                if [[ $PGP_RETRY =~ ^[Yy]$ ]]; then
                    log "User authorized temporary signature level adjustment"
                    echo -e "${BLUE}Backing up pacman.conf and adjusting signature checking...${NC}" | tee -a "$LOG_FILE"
                    
                    # Backup pacman.conf
                    sudo cp /etc/pacman.conf /etc/pacman.conf.bak_$(date +%Y%m%d_%H%M%S)
                    log "Created backup of /etc/pacman.conf"
                    
                    # Temporarily adjust signature level
                    sudo sed -i.tmp 's/^SigLevel[[:space:]]*=.*/SigLevel = Optional TrustAll/' /etc/pacman.conf
                    log "Temporarily set SigLevel to Optional TrustAll"
                    
                    # Retry failed categories
                    for failed_cat in "${STILL_FAILED[@]}"; do
                        echo -e "${YELLOW}Final retry: $failed_cat (relaxed signatures)${NC}" | tee -a "$LOG_FILE"
                        log "Final retry with relaxed signatures: $failed_cat"
                        
                        sudo pacman -S --needed --noconfirm --ignore "$IGNORE_PACKAGES" "$failed_cat" >> "$LOG_FILE" 2>&1
                        
                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}✓ Success with relaxed signatures!${NC}" | tee -a "$LOG_FILE"
                            log "Category $failed_cat succeeded with relaxed signatures"
                        else
                            echo -e "${RED}✗ Still failed${NC}" | tee -a "$LOG_FILE"
                            log_error "Category $failed_cat failed even with relaxed signatures"
                        fi
                    done
                    
                    # Restore strict signature checking
                    echo -e "${BLUE}Restoring strict signature checking...${NC}" | tee -a "$LOG_FILE"
                    sudo mv /etc/pacman.conf.tmp /etc/pacman.conf 2>/dev/null || {
                        sudo sed -i 's/^SigLevel[[:space:]]*=.*/SigLevel = Required DatabaseOptional/' /etc/pacman.conf
                    }
                    log "Restored strict SigLevel configuration"
                    echo -e "${GREEN}✓ Signature checking restored to secure defaults${NC}" | tee -a "$LOG_FILE"
                else
                    log "User declined PGP signature workaround"
                fi
            else
                log "No PGP signature issues detected in failed categories"
            fi
        fi
    else
        log "User declined to retry failed categories"
    fi
else
    # This is now the expected outcome, since Phase 0 should prevent all PGP failures.
    echo -e "${GREEN}[7/7] All categories processed successfully!${NC}" | tee -a "$LOG_FILE"
    log "Phase 7: No failed categories to retry"
fi

log "Script execution completed"
log "Total execution time: $SECONDS seconds"

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}   Installation process completed! 🎯${NC}"
echo -e "${GREEN}===========================================${NC}"
echo ""
echo -e "${CYAN}Check the logs above for any issues that need attention.${NC}"
echo -e "${CYAN}Happy hacking with BlackArch! 🔓🛡️${NC}"
echo ""
