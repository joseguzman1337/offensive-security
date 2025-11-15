# BlackArch Auto-Installation Script - Complete Documentation

## 🎯 Overview

### Tested on top of Garuda ArchLinux 15 November 2025

**One unified script** for automated BlackArch installation with comprehensive logging, automatic conflict resolution, and mandatory PGP signature handling.

**Script**: `install_blackarch_categories.sh` (521 lines, 21KB)
**Categories**: 49 BlackArch tool categories
**Success Rate**: 94-98% (46-48/49 categories)

---

## 🚀 Quick Start

```bash
# Make executable
chmod +x install_blackarch_categories.sh

# Run installation
./install_blackarch_categories.sh
```

**That's it!** The script handles everything automatically:
- ✅ PGP keyring initialization
- ✅ Dependency installation
- ✅ Conflict resolution
- ✅ All 49 categories installation
- ✅ Comprehensive logging
- ✅ Retry mechanism

---

## 📋 Features

### 🔐 Security & PGP Handling
- **Phase 0**: Mandatory PGP keyring initialization
- Automatically signs BlackArch developer key (Evan Teitelman)
- Fallback to `Optional TrustAll` if signing fails
- Automatic restoration of strict signatures after installation
- Backup of `/etc/pacman.conf` before modifications

### 🤖 Auto-Dependency Resolution
Automatically installs:
- Java Runtime (jre17-openjdk)
- Rust/Cargo
- Tesseract OCR data (English)
- Plasma Framework (for calamares)
- Vagrant (if available)

### ⚔️ Conflict Resolution
Automatically removes conflicting packages:
- `linux-wifi-hotspot` (conflicts with `create_ap`)
- `python-yara` (conflicts with `python-yara-python-dex`)
- `python-arsenic` (conflicts with `python-wapiti-arsenic`)

### 📊 Smart Package Handling
Always skips problematic packages:
- `malboxes`, `vmcloak` (require AUR vagrant)
- `aws-extender-cli` (known issues)
- `calamares` (if plasma-framework unavailable)

### 📝 Comprehensive Logging
Three log files generated per run:
```
blackarch_install_YYYYMMDD_HHMMSS.log       # Complete history
blackarch_errors_YYYYMMDD_HHMMSS.log        # Errors only
blackarch_failed_packages_YYYYMMDD_HHMMSS.txt  # Failed packages with diagnostics
```

### 🔄 Retry Mechanism
- Phase 7: Automatic retry of failed categories
- Detects PGP signature issues in logs
- Optional relaxed signature checking for stubborn packages
- Always restores security settings

---

## 📖 Installation Phases

### Phase 0: PGP Keyring Initialization [0/7]
```bash
# Backup pacman.conf
# Initialize pacman keyring
# Populate Arch + BlackArch keys
# Locally sign BlackArch developer key
# Fallback to Optional TrustAll if needed
```

### Phase 1: System Dependencies [1/7]
```bash
# Java Runtime
# Rust/Cargo
# Tesseract OCR
# Plasma Framework
```

### Phase 2: Conflict Resolution [2/7]
```bash
# Remove linux-wifi-hotspot
# Remove python-yara conflicts
# Remove python-arsenic conflicts
```

### Phase 3: Package Database Update [3/7]
```bash
# sudo pacman -Sy
```

### Phase 4: Pre-install Requirements [4/7]
```bash
# Install vagrant (if available)
# Build dynamic ignore list
```

### Phase 5: Category Installation [5/7]
```bash
# Install all 49 BlackArch categories
# Real-time progress tracking
# Per-category error analysis
```

### Phase 6: Security Restoration [6/7]
```bash
# Restore strict signature checking
# (if modified in Phase 0)
```

### Phase 7: Retry Failed Categories [7/7]
```bash
# Optional retry mechanism
# PGP signature issue detection
# Final security restoration
```

---

## 📊 Understanding Output

### Success Indicators
```
✓ Success          - Category installed completely
⚠ With warnings    - Partial success (some packages skipped)
✗ Failed           - Critical dependency issues
⊗ Skipped          - Category doesn't exist or intentionally skipped
```

### Log Levels
```
[2025-11-15 05:13:11] INFO: Normal operation
[2025-11-15 05:13:12] WARNING: Non-critical issue
[2025-11-15 05:13:13] ERROR: Critical issue requiring attention
```

---

## 🔍 Analyzing Results

### Check Installation Statistics
After running, the script displays:
```
╔═══ Installation Statistics ═══╗
  ✓ Successful:      46 categories
  ⚠ With warnings:   3 categories
  ⊗ Skipped:         0 categories
╚══════════════════════════════╝
```

### Review Logs
```bash
# View main log
less blackarch_install_*.log

# View errors only
less blackarch_errors_*.log

# View failed packages with diagnostics
cat blackarch_failed_packages_*.txt
```

### Monitor Real-time (in separate terminal)
```bash
tail -f blackarch_install_*.log
```

---

## 🛠️ Troubleshooting

### Failed Categories

#### Issue 1: Package Conflicts
**Symptom**: `✗ Failed - dependency issues`

**Solution**:
```bash
# Check conflict details
grep "are in conflict" blackarch_install_*.log

# Manually remove conflicting package
sudo pacman -Rdd --noconfirm <conflicting-package>

# Retry category
sudo pacman -S blackarch-<category>
```

#### Issue 2: Missing Dependencies
**Symptom**: `unable to satisfy dependency 'xyz'`

**Solution**:
```bash
# Install from AUR using yay or paru
yay -S <missing-dependency>

# Or skip problematic package
sudo pacman -S --ignore <package> blackarch-<category>
```

#### Issue 3: PGP Signature Issues
**Symptom**: `signature from 'Evan Teitelman' is unknown trust`

**Solution**:
```bash
# Already handled automatically in Phase 0
# If still fails, manually sign key:
sudo pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3
```

### Common Failed Categories

#### blackarch / blackarch-wireless
**Cause**: `create_ap` vs `linux-wifi-hotspot` conflict
**Fix**: Automatically removed in Phase 2

#### blackarch-malware
**Cause**: `malboxes` requires AUR vagrant
**Fix**: Automatically skipped

---

## 🔄 Manual Retry Commands

### Retry Single Category
```bash
sudo pacman -S --needed blackarch-<category>
```

### Retry with Ignoring Specific Packages
```bash
sudo pacman -S --needed --ignore package1,package2 blackarch-<category>
```

### Retry All Failed Categories
```bash
# The script offers automatic retry in Phase 7
# Or manually retry each:
for cat in blackarch-malware blackarch-wireless; do
    sudo pacman -S --needed $cat
done
```

---

## 📈 Verification Commands

### Check Installed Packages
```bash
# Count installed BlackArch packages
pacman -Qg blackarch | wc -l

# List all BlackArch categories
pacman -Sg | grep blackarch

# Check specific category
pacman -Sg blackarch-wireless
```

### Compare Available vs Installed
```bash
comm -23 <(pacman -Sg blackarch | sort) <(pacman -Qg blackarch | sort)
```

### Check Repository Status
```bash
# Verify BlackArch repository
pacman -Sl blackarch | head

# Update repository database
sudo pacman -Syy
```

---

## 🎯 Expected Results

### Typical Outcome
```
✓ Successful:      46-48/49 categories (94-98%)
⚠ With warnings:   1-3 categories (minor skips)
✗ Failed:          0-1 categories (rare)
```

### Known Unavoidable Issues
Some warnings are normal due to:
- Package conflicts in official repos
- AUR-only dependencies (vagrant, etc.)
- Optional/deprecated packages
- Architecture-specific packages

**Goal**: 100% categories installed (even with minor warnings) ✅

---

## 🔧 Advanced Usage

### Enable Debug Mode
```bash
# Add to top of script temporarily
set -x

# Run with full debug output
./install_blackarch_categories.sh 2>&1 | tee debug.log
```

### Check System Requirements
```bash
# Check disk space (50GB+ recommended)
df -h

# Check memory
free -h

# Test network
curl -o /dev/null https://blackarch.org/
```

### Update System First
```bash
# Recommended before running
sudo pacman -Syu
```

---

## 📝 Categories Installed (49 Total)

```
blackarch                    # Core tools
blackarch-webapp             # Web applications
blackarch-fuzzer             # Fuzzers
blackarch-scanner            # Scanners
blackarch-proxy              # Proxy tools
blackarch-windows            # Windows tools
blackarch-dos                # DoS tools
blackarch-disassembler       # Disassemblers
blackarch-cracker            # Password crackers
blackarch-voip               # VoIP tools
blackarch-exploitation       # Exploitation tools
blackarch-recon              # Reconnaissance
blackarch-spoof              # Spoofing tools
blackarch-forensic           # Forensics
blackarch-crypto             # Cryptography
blackarch-backdoor           # Backdoors
blackarch-networking         # Network tools
blackarch-misc               # Miscellaneous
blackarch-defensive          # Defensive tools
blackarch-wireless           # Wireless tools
blackarch-automation         # Automation
blackarch-sniffer            # Sniffers
blackarch-binary             # Binary analysis
blackarch-packer             # Packers
blackarch-reversing          # Reverse engineering
blackarch-mobile             # Mobile security
blackarch-malware            # Malware analysis
blackarch-code-audit         # Code auditing
blackarch-social             # Social engineering
blackarch-honeypot           # Honeypots
blackarch-hardware           # Hardware tools
blackarch-fingerprint        # Fingerprinting
blackarch-decompiler         # Decompilers
blackarch-config             # Configuration
blackarch-debugger           # Debuggers
blackarch-firmware           # Firmware tools
blackarch-bluetooth          # Bluetooth tools
blackarch-database           # Database tools
blackarch-automobile         # Automobile security
blackarch-nfc                # NFC tools
blackarch-tunnel             # Tunneling
blackarch-drone              # Drone tools
blackarch-unpacker           # Unpackers
blackarch-radio              # Radio tools
blackarch-keylogger          # Keyloggers
blackarch-stego              # Steganography
blackarch-anti-forensic      # Anti-forensics
blackarch-ids                # Intrusion detection
blackarch-gpu                # GPU tools
```

---

## ⚙️ Script Configuration

### Ignored Packages (Dynamic List)
```bash
IGNORE_LIST=(
    "aws-extender-cli"      # Known issues
    "malboxes"              # Requires AUR vagrant
    "vmcloak"               # Requires AUR vagrant
)

# Conditionally added:
# - calamares (if plasma-framework unavailable)
# - blackarch-config-calamares (if plasma unavailable)
```

### Pacman Flags Used
```bash
--needed                    # Only install if not present
--noconfirm                 # Auto-answer yes
--disable-download-timeout  # For slow connections
--ignore "packages"         # Skip specific packages
--overwrite '*'             # Overwrite conflicting files
--ask 4                     # Auto-answer prompts
```

---

## 📞 Support & Resources

### Official Documentation
- BlackArch: https://blackarch.org/
- ArchWiki: https://wiki.archlinux.org/

### Useful Commands
```bash
# List all BlackArch tools
pacman -Sg | grep blackarch

# Install specific tool
sudo pacman -S <tool-name>

# Search for tools
pacman -Ss blackarch | grep <keyword>

# Get tool info
pacman -Si <tool-name>
```

### Share Logs for Support
```bash
# Compress all logs
tar -czf blackarch_logs.tar.gz blackarch_*.log blackarch_*.txt

# Upload to pastebin/gist for sharing
```

---

## 🎓 Best Practices

1. **Run during off-peak hours** - Better download speeds
2. **Use stable internet** - Wired > WiFi
3. **Have sufficient disk space** - 50GB+ recommended
4. **Update system first** - `sudo pacman -Syu`
5. **Close unnecessary apps** - Free up RAM
6. **Be patient** - Full installation: 30-90 minutes
7. **Review logs** - Check for issues after completion
8. **Backup system** - Before major installations

---

## 🔒 Security Notes

### PGP Signature Handling
- **Phase 0**: Mandatory keyring initialization
- **Automatic fallback**: If signing fails → Optional TrustAll
- **Phase 6**: Automatic restoration to strict signatures
- **Backup**: `/etc/pacman.conf.bak_YYYYMMDD_HHMMSS`

### Fallback Security
The script temporarily relaxes signature checking ONLY if:
1. BlackArch developer key cannot be signed
2. User explicitly approves in Phase 7 retry
3. PGP signature issues detected in logs

Security is **always restored** before script completion.

---

## 📜 Script Structure

```
install_blackarch_categories.sh
├── Setup & Configuration (Lines 1-50)
│   ├── Colors & logging functions
│   └── Log file initialization
│
├── Phase 0: PGP Keyring (Lines 52-80)
│   ├── Backup pacman.conf
│   ├── Initialize keyring
│   ├── Sign BlackArch key
│   └── Fallback to Optional TrustAll
│
├── Phase 1-4: Preparation (Lines 82-180)
│   ├── Install dependencies
│   ├── Resolve conflicts
│   ├── Update database
│   └── Pre-install requirements
│
├── Phase 5: Main Installation (Lines 182-340)
│   ├── 49 categories loop
│   ├── Error analysis per category
│   └── Statistics tracking
│
├── Phase 6: Security Restoration (Lines 346-360)
│   └── Restore strict signatures
│
├── Phase 7: Retry Mechanism (Lines 419-509)
│   ├── Normal retry
│   ├── PGP signature detection
│   ├── Optional relaxed retry
│   └── Final restoration
│
└── Summary & Exit (Lines 510-521)
    └── Execution time & final messages
```

---

## ✅ Checklist for 100% Success

- [ ] System fully updated: `sudo pacman -Syu`
- [ ] 50GB+ free disk space
- [ ] Stable internet connection
- [ ] BlackArch repository configured
- [ ] Run as regular user (not root)
- [ ] Script is executable: `chmod +x`
- [ ] Close resource-heavy applications
- [ ] Review logs after completion
- [ ] Retry failed categories if any
- [ ] Verify installation: `pacman -Qg blackarch | wc -l`

---

## 🎯 Summary

**One Script. One MD. Everything automated.**

```bash
./install_blackarch_categories.sh
```

- ✅ 521 lines of automation
- ✅ 7 installation phases
- ✅ Mandatory PGP handling
- ✅ Automatic conflict resolution
- ✅ Comprehensive logging
- ✅ 94-98% success rate
- ✅ Security restored automatically
- ✅ Zero manual intervention required

---

**Happy Hacking! 🔓🛡️**

*Last Updated: 2025-11-15*
