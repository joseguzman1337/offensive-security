# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is a BlackArch security tools installation and configuration repository for Arch-based Linux distributions (tested on Garuda Linux). It contains automated installation scripts for BlackArch penetration testing tools and security assessment infrastructure with Metasploit/Nmap.

## Architecture

### Core Components

**Main Installation Script** (`install_blackarch_categories.sh`)

- 587-line Bash script with 7 installation phases
- Automated dependency resolution and conflict handling
- PGP keyring management with fallback mechanisms
- Installs all 51 BlackArch tool categories (~2,869+ security tools)
- Comprehensive logging to 3 separate files per run
- Retry mechanism for failed categories with signature workaround

**Alternative Python Installer** (`optional/blackarch_installer.py`)

- Fallback approach using Python with mirror selection
- Location-based mirror prioritization
- Multiple AUR helper support (pacman, yay, paru, pacaur)
- Modular design with separate modules for packages, repos, helpers

**Security Assessment Infrastructure** (`r7/`)

- Metasploit Framework + Nmap automated scanning setup
- PostgreSQL database integration for Metasploit
- NSE vulnerability scripts (Vulscan, Nmap-Vulners)
- CVE database integration (8 different sources)
- Workspace management and automated scanning pipelines

### Installation Phases (Main Script)

0. **Pre-Phase**: Install basic dependencies (jre17-openjdk, rust, tesseract-data-eng, erlang, wings3d)
1. **Phase 0**: PGP keyring initialization + conflict resolution + dependency installation
   - Conflicts removed BEFORE installing replacement packages
   - Installs: python-yara-python-dex, python-wapiti-arsenic, create_ap, vagrant (from AUR)
2. **Phase 1**: Dependency verification
3. **Phase 2**: Verify conflicts are resolved (safety check)
4. **Phase 3**: Package database update
5. **Phase 4**: Final sync
6. **Phase 5**: All 51 category installation
7. **Phase 6**: Security restoration (strict signature checking)
8. **Phase 7**: Retry mechanism for failed categories

### Key Design Patterns

**PGP Signature Handling**

- Proactive `SigLevel = Optional TrustAll` adjustment (lines 84-86 in main script)
- Automatic backup of pacman.conf with timestamps
- Always restores strict signatures after installation
- User-consent required for signature workaround in retry phase

**Conflict Resolution Strategy**

- **CRITICAL FIX**: Conflicts are now removed in Phase 0 BEFORE installing replacement packages
- Previously Phase 2 removed conflicts AFTER Phase 0 tried to install replacements (causing failures)
- Uses `python-yara-python-dex` instead of `python-yara`
- Uses `python-wapiti-arsenic` instead of `python-arsenic`
- Uses `create_ap` instead of `linux-wifi-hotspot`
- Phase 2 now serves as a verification/safety check only

**Minimal Skip Policy**

- Only excludes: `aws-extender-cli`, `calamares`, `blackarch-config-calamares`, `plasma-framework`
- Mandatory AUR installation of `vagrant` (required for malboxes)

## Common Development Commands

### Running Main Installation

```bash
# Make executable (if needed)
chmod +x install_blackarch_categories.sh

# Run full installation (requires AUR helper: paru or yay)
./install_blackarch_categories.sh

# Installation logs generated:
# - blackarch_install_YYYYMMDD_HHMMSS.log (complete history)
# - blackarch_errors_YYYYMMDD_HHMMSS.log (errors only)
# - blackarch_failed_packages_YYYYMMDD_HHMMSS.txt (diagnostics)
```

### Verification Commands

```bash
# Count installed BlackArch packages
pacman -Qg blackarch | wc -l

# List all BlackArch categories (should show 51)
pacman -Sg | grep blackarch

# Check specific category contents
pacman -Sg blackarch-wireless

# Verify package conflicts
comm -23 <(pacman -Sg blackarch | sort) <(pacman -Qg blackarch | sort)

# Check repository status
pacman -Sl blackarch | head
```

### Manual Category Installation

```bash
# Install single category
sudo pacman -S --needed blackarch-<category>

# Retry with ignoring specific packages
sudo pacman -S --needed --ignore package1,package2 blackarch-<category>

# Check for conflicts
grep "are in conflict" blackarch_install_*.log
```

### Keyring Management

```bash
# Fix keyring conflicts (use helper script)
./fix_blackarch_keyring.sh

# Manually sign BlackArch developer key
sudo pacman-key --lsign-key 4345771566D76038C7FEB43863EC0ADBEA87E4E3

# Reinitialize keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux blackarch
```

### Security Assessment Infrastructure (r7/)

```bash
# Install security infrastructure (Metasploit + Nmap)
./r7/install_security_infrastructure.sh

# Configure scan targets
nano ~/SA/sk/sk_ips

# Run automated security scan
~/SA/sk/quick_scan.sh
# OR
msfconsole -r ~/SA/sk/SAD.rc

# Monitor scan progress
tail -f ~/SA/sk/new_r7nmapScan_spool

# Check Metasploit database status
msfdb status

# Reinitialize Metasploit database (if needed)
msfdb reinit

# Check PostgreSQL service
systemctl status postgresql --no-pager

# Update NSE scripts
sudo nmap --script-updatedb
```

### Troubleshooting

```bash
# View main installation log
less blackarch_install_*.log

# View errors only
less blackarch_errors_*.log

# View failed packages with diagnostics
cat blackarch_failed_packages_*.txt

# Monitor real-time installation (separate terminal)
tail -f blackarch_install_*.log

# Clean pacman cache (if corrupted packages)
sudo pacman -Scc --noconfirm

# Update package database
sudo pacman -Syy
```

## System Requirements

### Prerequisites

- **OS**: Arch Linux or Arch-based distribution (Garuda Linux verified)
- **AUR Helper**: `paru` or `yay` (MANDATORY for vagrant installation)
- **Disk Space**: 50GB+ recommended
- **Network**: Stable internet connection (wired preferred)
- **Privileges**: Regular user with sudo access (do NOT run as root)

### Mandatory Dependencies (Auto-installed in Phase 0)

- `jre17-openjdk` (Java Runtime)
- `rust` and `cargo`
- `tesseract-data-eng` (OCR data)
- `vagrant` (from AUR via paru/yay)
- `python-yara-python-dex` (replaces python-yara)
- `python-wapiti-arsenic` (replaces python-arsenic)
- `create_ap` (replaces linux-wifi-hotspot)

### Excluded Packages

- `plasma-framework` - Not needed
- `calamares` and `blackarch-config-calamares` - Installation tools, not needed

## Security Notes

### PGP Signature Security Model

- Script temporarily relaxes signature checking ONLY when:
  1. BlackArch developer key cannot be signed (Phase 0)
  2. User explicitly approves in Phase 7 retry
  3. PGP signature issues detected in logs
- Security is ALWAYS restored before script completion
- Multiple timestamped backups of `/etc/pacman.conf` are created

### Sensitive Values

All secrets and tokens must be masked according to repository rules. Never echo or log PGP keys or sensitive configuration.

### Authorized Use Only

The security tools in this repository are for:

- Authorized security assessments
- Educational purposes
- Networks you own or have explicit permission to test

**Unauthorized scanning is illegal and unethical.**

## Expected Success Rate

**Verified Results**: 100% success rate (51/51 categories, 2,869+ tools)

- Last verified: 2025-11-15
- Platform: Garuda Linux (Arch-based)
- All 51 BlackArch categories installed successfully
- Zero warnings, zero failures

## Log Analysis

### Success Indicators

- `✓ Success` - Category installed completely
- `⚠ With warnings` - Partial success (some packages skipped)
- `✗ Failed` - Critical dependency issues
- `⊗ Skipped` - Category doesn't exist or intentionally skipped

### Common Error Patterns

- `signature from 'Evan Teitelman' is unknown trust` → PGP keyring issue (auto-handled)
- `are in conflict` → Package conflict (auto-resolved in Phase 2)
- `unable to satisfy dependency` → Missing dependency from AUR

## File Structure Reference

```
.
├── install_blackarch_categories.sh    # Main 587-line installer (USE THIS)
├── fix_blackarch_keyring.sh           # Keyring conflict resolution
├── readme.md                           # Comprehensive documentation
├── optional/                           # Alternative Python-based installer
│   ├── blackarch_installer.py         # Python installer entry point
│   ├── blackarch_packages.py          # Package definitions
│   ├── blackarch_repos.py             # Mirror management
│   ├── helpers.py                     # Utility functions
│   ├── missing_helpers.py             # AUR helper installation
│   ├── problematic_packages.py        # Known issue handling
│   └── readme.md                      # Python installer docs
├── r7/                                # Security assessment infrastructure
│   ├── install_security_infrastructure.sh  # Metasploit/Nmap setup
│   ├── README.md                      # Security infrastructure docs
│   └── INSTALL_GUIDE.md               # Step-by-step guide
└── SA/                                # Security assessment workspace (created by r7/)
    └── sk/                            # Scan configuration directory
        ├── sk_ips                     # Target IPs/hostnames
        ├── bl                         # Blacklist/exclusions
        ├── SAD.rc                     # Metasploit scanning pipeline
        ├── setup_workspace.rc         # Workspace configuration
        ├── quick_scan.sh              # Quick scan launcher
        └── cleanup_scans.sh           # Cleanup utility
```

## 51 BlackArch Categories

blackarch, blackarch-webapp, blackarch-fuzzer, blackarch-scanner, blackarch-proxy, blackarch-windows, blackarch-dos, blackarch-disassembler, blackarch-sniffer, blackarch-voip, blackarch-fingerprint, blackarch-networking, blackarch-recon, blackarch-cracker, blackarch-exploitation, blackarch-spoof, blackarch-forensic, blackarch-crypto, blackarch-backdoor, blackarch-defensive, blackarch-wireless, blackarch-automation, blackarch-radio, blackarch-binary, blackarch-packer, blackarch-reversing, blackarch-mobile, blackarch-malware, blackarch-code-audit, blackarch-social, blackarch-honeypot, blackarch-misc, blackarch-wordlist, blackarch-decompiler, blackarch-config, blackarch-debugger, blackarch-bluetooth, blackarch-database, blackarch-automobile, blackarch-hardware, blackarch-nfc, blackarch-tunnel, blackarch-drone, blackarch-unpacker, blackarch-firmware, blackarch-keylogger, blackarch-stego, blackarch-anti-forensic, blackarch-ids, blackarch-threat-model, blackarch-gpu

## Best Practices

1. **Run during off-peak hours** for better download speeds
2. **Use stable wired connection** over WiFi
3. **Update system first**: `sudo pacman -Syu`
4. **Close resource-heavy applications** to free RAM
5. **Be patient** - Full installation takes 30-90 minutes
6. **Review logs after completion** for any issues
7. **Backup system before major installations**
8. **Never run scripts as root** - use regular user with sudo

## Integration Notes

When modifying scripts in this repository:

- Maintain the 7-phase installation structure
- Preserve PGP signature handling logic (lines 84-86, 415-424, 555-560)
- Keep conflict resolution in Phase 2
- Use timestamped log files for all operations
- Always restore security settings before exit
- Test on Arch-based distributions only
- Ensure AUR helper detection works for both paru and yay
