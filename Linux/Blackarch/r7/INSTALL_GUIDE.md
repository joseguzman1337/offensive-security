# Security Infrastructure - Zero Intervention Installation Guide

## Quick Install

### One-Command Installation

```bash
cd ~/Downloads && ./install_security_infrastructure.sh
```

That's it! The script handles everything automatically.

## What Gets Installed

### Core Components

- PostgreSQL 18.1+ (database backend)
- Nmap 7.98+ (network scanner)
- Metasploit Framework 6.4+ (exploitation framework)
- NSE Scripts (Vulscan, Nmap-Vulners)
- Configuration files and helper scripts

### Installation Location

```
~/SA/
├── sk/
│   ├── sk_ips              # Edit this with your targets
│   ├── bl                  # Exclusion list
│   ├── SAD.rc              # Main scanning pipeline
│   ├── setup_workspace.rc  # Workspace configuration
│   ├── quick_scan.sh       # Quick scan launcher ⭐
│   └── cleanup_scans.sh    # Cleanup utility
├── logs/
├── README.md               # Full documentation
└── INSTALLATION_SUMMARY.txt # Installation results
```

## Features

### ✅ Zero Intervention

- Automatic dependency resolution
- No prompts or manual input required
- Smart conflict resolution
- Graceful error handling
- Progress tracking with statistics

### ✅ Smart Installation

- Detects existing installations
- Skips already installed components
- Validates tools before configuration
- Creates backup-safe directory structure
- Generates comprehensive documentation

### ✅ Complete Setup

- PostgreSQL database initialized
- Metasploit workspace configured
- NSE vulnerability scripts installed
- CVE databases downloaded
- Helper scripts ready to use

## Installation Process

### Steps Automated (12 total)

1. ✓ Create directory structure
2. ✓ Verify sudo access
3. ✓ Install base packages (git, neofetch, nginx)
4. ✓ Install and configure PostgreSQL
5. ✓ Check core tools (Nmap, Metasploit)
6. ✓ Initialize Metasploit database
7. ✓ Install NSE vulnerability scripts
8. ✓ Configure Metasploit workspace
9. ✓ Create configuration files
10. ✓ Create helper scripts
11. ✓ Generate documentation
12. ✓ Create installation summary

### Output Example

```
╔════════════════════════════════════════════════════════════╗
║     Security Infrastructure Auto-Installer (v2.0)        ║
║              Zero Intervention Required                   ║
╚════════════════════════════════════════════════════════════╝

┌─ [1/12] Creating directory structure
└─ ✓ Directories created at /home/user/SA

┌─ [2/12] Verifying sudo access
└─ ✓ Sudo access verified

... (continues for all 12 steps)

╔════════════════════════════════════════════════════════════╗
║              Installation Complete!                        ║
╚════════════════════════════════════════════════════════════╝

Installation Statistics:
  ✓ Successful steps: 10
  ⚠ Warnings:         2
  ⊙ Skipped:          0
```

## After Installation

### 1. Configure Targets

```bash
nano ~/SA/sk/sk_ips
```

Add targets (one per line):

```
192.168.1.100
target.example.com
10.0.0.0/24
```

### 2. Configure Exclusions (Optional)

```bash
nano ~/SA/sk/bl
```

Add IPs to exclude:

```
192.168.1.1
10.0.0.1
```

### 3. Run Your First Scan

```bash
~/SA/sk/quick_scan.sh
```

### 4. Monitor Progress

```bash
# In another terminal
tail -f ~/SA/sk/new_r7nmapScan_spool
```

### 5. View Results

```bash
# In Metasploit console
msfconsole
workspace sk
hosts
services
vulns
```

## Verification Commands

### Check Installation Status

```bash
# View summary
cat ~/SA/INSTALLATION_SUMMARY.txt

# Check PostgreSQL
systemctl status postgresql --no-pager

# Check Metasploit database
msfdb status

# List NSE scripts
ls /usr/share/nmap/scripts/vulscan/
ls /usr/share/nmap/scripts/nmap-vulners/
```

### Test Components

```bash
# Test Nmap
nmap --version

# Test Metasploit
msfconsole --version

# Test database connection
msfconsole -q -x "db_status; exit"
```

## Troubleshooting

### Script Issues

**Permission Denied**

```bash
chmod +x ~/Downloads/install_security_infrastructure.sh
```

**Sudo Password Required**

- Script will prompt once for sudo password
- Password is kept alive during installation

### Installation Issues

**PostgreSQL Won't Start**

```bash
sudo -u postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data
sudo systemctl start postgresql
```

**Metasploit Database Issues**

```bash
msfdb reinit
msfdb status
```

**NSE Scripts Not Found**

```bash
sudo nmap --script-updatedb
locate vulscan.nse
```

**Permission Issues**

```bash
sudo chown -R $USER:$USER ~/SA/
chmod +x ~/SA/sk/*.sh
```

## Manual Installation (If Needed)

### Install Nmap

```bash
sudo pacman -S nmap
```

### Install Metasploit (AUR)

```bash
yay -S metasploit
# or
paru -S metasploit
```

### Install PostgreSQL

```bash
sudo pacman -S postgresql
sudo -u postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data
sudo systemctl enable --now postgresql
```

## Usage Examples

### Quick Vulnerability Scan

```bash
nmap -sV --script vuln target.example.com
```

### Full Metasploit Pipeline

```bash
msfconsole -r ~/SA/sk/SAD.rc
```

### Custom Scan with Vulscan

```bash
nmap -sV --script vulscan --script-args vulscandb=cve.csv target.com
```

### Manual Metasploit Workflow

```bash
msfconsole
workspace sk
db_nmap -sV -sC target.example.com
hosts
services
vulns
```

## Maintenance

### Update Tools

```bash
# Update Nmap NSE scripts
sudo nmap --script-updatedb

# Update Metasploit
msfupdate

# Update vulnerability databases
cd /usr/share/nmap/scripts/vulscan/
sudo git pull
```

### Clean Old Scans

```bash
~/SA/sk/cleanup_scans.sh
```

### Backup Configuration

```bash
tar -czf ~/SA-backup-$(date +%Y%m%d).tar.gz ~/SA/
```

## Security Best Practices

### ⚠️ Legal Compliance

- **Only scan authorized networks**
- Obtain written permission before scanning
- Understand local laws regarding security testing
- Document all authorized targets

### 🔒 Safe Usage

- Test in isolated lab environments first
- Use exclusion lists for critical infrastructure
- Monitor scan impact on network
- Limit scan intensity for production networks
- Keep logs for audit purposes

### 🛡️ Ethics

- Educational purposes only
- Responsible disclosure of vulnerabilities
- Respect privacy and data protection
- Follow professional security guidelines

## Support & Resources

### Documentation

- Full docs: `~/SA/README.md`
- Installation summary: `~/SA/INSTALLATION_SUMMARY.txt`

### Online Resources

- Nmap: https://nmap.org/
- Metasploit: https://www.metasploit.com/
- Vulscan: https://github.com/scipag/vulscan
- Nmap-Vulners: https://github.com/vulnersCom/nmap-vulners

### Community

- Nmap NSE Documentation: https://nmap.org/nsedoc/
- Metasploit Documentation: https://docs.metasploit.com/
- Rapid7 Community: https://community.rapid7.com/

## Script Features

### Intelligent Detection

- Checks if tools already installed
- Detects existing databases
- Skips unnecessary steps
- Validates before proceeding

### Error Resilience

- Continues on non-critical errors
- Logs all warnings
- Provides detailed error messages
- Graceful degradation

### Progress Tracking

- Real-time step counter (1/12, 2/12, etc.)
- Color-coded output (✓ ⚠ ⊙)
- Final statistics summary
- Detailed installation log

### Color-Coded Output

- 🔵 Blue: Current step
- 🟢 Green: Success
- 🟡 Yellow: Warning
- 🔵 Cyan: Skipped
- 🔴 Red: Error

## Uninstallation

### Remove Installation

```bash
# Remove SA directory
rm -rf ~/SA/

# Stop services (optional)
sudo systemctl stop postgresql
sudo systemctl disable postgresql

# Remove packages (optional)
sudo pacman -R postgresql nginx
```

### Keep Configuration

```bash
# Backup before removing
cp -r ~/SA/ ~/SA-backup/
```

---

**Installation Script:** `~/Downloads/install_security_infrastructure.sh`
**Installation Time:** ~5-10 minutes
**Disk Space Required:** ~500MB (excluding scan results)

**Ready to install? Run:**

```bash
cd ~/Downloads && ./install_security_infrastructure.sh
```
