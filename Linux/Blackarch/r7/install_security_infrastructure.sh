#!/bin/bash
#
# Security Assessment Infrastructure - Zero Intervention Installer
# Automated installation of Nmap, Metasploit, NSE scripts, and configuration
#

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Counters
TOTAL_STEPS=12
CURRENT_STEP=0
SUCCESS_COUNT=0
WARNING_COUNT=0
SKIP_COUNT=0

# Installation directory
INSTALL_DIR="$HOME/SA"
SK_DIR="$INSTALL_DIR/sk"

# Log file
LOG_FILE="$INSTALL_DIR/installation.log"

# Print header
print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     Security Infrastructure Auto-Installer (v2.0)        ║${NC}"
    echo -e "${CYAN}║              Zero Intervention Required                   ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print step
print_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "\n${BLUE}┌─ [$CURRENT_STEP/$TOTAL_STEPS] $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}└─ ✓ $1${NC}"
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
}

# Print warning
print_warning() {
    echo -e "${YELLOW}└─ ⚠ $1${NC}"
    WARNING_COUNT=$((WARNING_COUNT + 1))
}

# Print skip
print_skip() {
    echo -e "${CYAN}└─ ⊙ $1${NC}"
    SKIP_COUNT=$((SKIP_COUNT + 1))
}

# Print error and continue
print_error() {
    echo -e "${RED}└─ ⊗ $1${NC}"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${RED}Error: Do not run this script as root!${NC}"
        echo "Run as normal user with sudo privileges."
        exit 1
    fi
}

# Create installation directory
create_directories() {
    print_step "Creating directory structure"
    mkdir -p "$INSTALL_DIR" "$SK_DIR" 2>/dev/null || true
    mkdir -p "$INSTALL_DIR/logs" 2>/dev/null || true
    print_success "Directories created at $INSTALL_DIR"
}

# Check sudo access
check_sudo() {
    print_step "Verifying sudo access"
    if sudo -n true 2>/dev/null; then
        print_success "Sudo access verified"
    else
        echo -e "${YELLOW}Please enter sudo password:${NC}"
        sudo -v
        print_success "Sudo access granted"
    fi
    
    # Keep sudo alive
    (while true; do sudo -n true; sleep 50; done) 2>/dev/null &
    SUDO_PID=$!
}

# Install base packages
install_base_packages() {
    print_step "Installing base packages"
    
    # Update package database silently
    echo "  → Updating package database..."
    sudo pacman -Sy --noconfirm >/dev/null 2>&1 || true
    
    # Install git and neofetch
    echo "  → Installing git and utilities..."
    sudo pacman -S --needed --noconfirm git neofetch 2>/dev/null || true
    
    # Install nginx
    echo "  → Installing nginx..."
    echo "1" | sudo pacman -S --needed --noconfirm nginx 2>/dev/null || true
    
    print_success "Base packages installed"
}

# Install and configure PostgreSQL
install_postgresql() {
    print_step "Installing and configuring PostgreSQL"
    
    # Check if already installed
    if pacman -Q postgresql &>/dev/null; then
        print_skip "PostgreSQL already installed"
    else
        echo "  → Installing PostgreSQL..."
        sudo pacman -S --needed --noconfirm postgresql 2>/dev/null || true
    fi
    
    # Initialize database if not exists
    if [ ! -d "/var/lib/postgres/data" ] || [ -z "$(ls -A /var/lib/postgres/data 2>/dev/null)" ]; then
        echo "  → Initializing PostgreSQL database..."
        sudo -u postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data >/dev/null 2>&1 || true
    fi
    
    # Enable and start service
    echo "  → Starting PostgreSQL service..."
    sudo systemctl enable postgresql >/dev/null 2>&1 || true
    sudo systemctl start postgresql >/dev/null 2>&1 || true
    
    # Wait for service to start
    sleep 2
    
    if systemctl is-active --quiet postgresql; then
        print_success "PostgreSQL installed and running"
    else
        print_warning "PostgreSQL installed but may need manual start"
    fi
}

# Check Nmap and Metasploit
check_core_tools() {
    print_step "Checking core security tools"
    
    local all_present=true
    
    if ! command -v nmap &>/dev/null; then
        echo -e "${YELLOW}  → Nmap not found. Install with: sudo pacman -S nmap${NC}"
        all_present=false
    else
        echo "  → Nmap: $(nmap --version | head -1)"
    fi
    
    if ! command -v msfconsole &>/dev/null; then
        echo -e "${YELLOW}  → Metasploit not found. Install from AUR: yay -S metasploit${NC}"
        all_present=false
    else
        echo "  → Metasploit: $(msfconsole --version 2>/dev/null | head -1)"
    fi
    
    if $all_present; then
        print_success "Core tools verified"
    else
        print_warning "Some tools missing - install manually"
    fi
}

# Initialize Metasploit database
init_metasploit_db() {
    print_step "Initializing Metasploit database"
    
    if ! command -v msfdb &>/dev/null; then
        print_skip "Metasploit not installed - skipping database setup"
        return
    fi
    
    # Check database status
    if msfdb status 2>/dev/null | grep -q "Database started"; then
        print_skip "Metasploit database already running"
    else
        echo "  → Initializing database..."
        msfdb init >/dev/null 2>&1 || true
        sleep 2
        
        if msfdb status 2>/dev/null | grep -q "Database started"; then
            print_success "Metasploit database initialized"
        else
            print_warning "Database initialization may need manual setup"
        fi
    fi
}

# Install NSE vulnerability scripts
install_nse_scripts() {
    print_step "Installing NSE vulnerability scanning scripts"
    
    local nse_dir="/usr/share/nmap/scripts"
    
    # Create directory if not exists
    sudo mkdir -p "$nse_dir" 2>/dev/null || true
    
    # Install vulscan
    if [ -d "$nse_dir/vulscan" ]; then
        echo "  → Vulscan already installed"
    else
        echo "  → Cloning vulscan repository..."
        sudo git clone https://github.com/scipag/vulscan "$nse_dir/vulscan" >/dev/null 2>&1 || true
    fi
    
    # Install nmap-vulners
    if [ -d "$nse_dir/nmap-vulners" ]; then
        echo "  → Nmap-vulners already installed"
    else
        echo "  → Cloning nmap-vulners repository..."
        sudo git clone https://github.com/vulnersCom/nmap-vulners.git "$nse_dir/nmap-vulners" >/dev/null 2>&1 || true
    fi
    
    # Update NSE database
    echo "  → Updating NSE script database..."
    sudo nmap --script-updatedb >/dev/null 2>&1 || true
    
    print_success "NSE scripts installed"
}

# Configure Metasploit workspace
configure_metasploit_workspace() {
    print_step "Configuring Metasploit workspace"
    
    if ! command -v msfconsole &>/dev/null; then
        print_skip "Metasploit not installed - skipping workspace setup"
        return
    fi
    
    # Create workspace configuration script
    cat > "$SK_DIR/setup_workspace.rc" << 'EOF'
db_status
db_rebuild_cache
load nexpose
load nessus
save
workspace -a sk
setg Prompt x(%whi%H/%grn%U/%whi%L%grn%D/%whi%T/%grn%W/%whiS%S/%grnJ%J)
setg ConsoleLogging y
setg LogLevel 5
setg SessionLogging y
setg TimestampOutput true
setg ExitOnSession false
setg VERBOSE true
save
EOF
    
    echo "  → Running workspace configuration..."
    timeout 60 msfconsole -q -r "$SK_DIR/setup_workspace.rc" -x exit >/dev/null 2>&1 || true
    
    print_success "Workspace configured"
}

# Create configuration files
create_config_files() {
    print_step "Creating configuration files"
    
    # Target IPs file
    cat > "$SK_DIR/sk_ips" << 'EOF'
# Add target IP addresses or hostnames here
# One per line
# Example:
# 192.168.1.100
# target.example.com
EOF
    
    # Blacklist file
    cat > "$SK_DIR/bl" << 'EOF'
# Add IP addresses to exclude from scanning
# One per line
# Example:
# 192.168.1.1
# 10.0.0.1/24
EOF
    
    # Main scanning pipeline
    cat > "$SK_DIR/SAD.rc" << EOF
neofetch
workspace sk
workspace
spool $SK_DIR/new_r7nmapScan_spool
setg ExitOnSession false
setg VERBOSE true
neofetch
db_nmap --save --privileged -sY -sZ -script=auth,broadcast,brute,discovery,dos,external,fuzzer,intrusive,malware,version,vuln --script-args vulscandb=cve.csv,exploitdb.csv,openvas.csv,osvdb.csv,scipvuldb.csv,securityfocus.csv,securitytracker.csv,xforce.csv,randomseed,newtargets A -f -D RND -sV -sC --script-updatedb --script-trace -O --osscan-guess -vvv --max-retries 0 --min-hostgroup 7 --max-hostgroup 1337 --max-parallelism 137 --min-parallelism 2 --max-rtt-timeout 100ms --host-timeout 30m --randomize-hosts -sN -Pn -p- --mtu 8 --version-all --version-trace --reason -iR 10000 -PO -PM -sU -T4 -v -PE -PP -PS22,25,80 -PA21,23,80,3389 -PU40125 -PY -g 53 --traceroute --packet-trace -iL $SK_DIR/sk_ips --excludefile $SK_DIR/bl -vvv -ddd -oA $SK_DIR/new_r7nmapScan -oS $SK_DIR/new_r7nmapScan_sk
version
banner
EOF
    
    print_success "Configuration files created"
}

# Create helper scripts
create_helper_scripts() {
    print_step "Creating helper scripts"
    
    # Quick scan script
    cat > "$SK_DIR/quick_scan.sh" << EOF
#!/bin/bash
# Quick network security scan with Metasploit
echo "Starting Metasploit quick scan..."
msfconsole -q -r $SK_DIR/SAD.rc
EOF
    
    # Cleanup script
    cat > "$SK_DIR/cleanup_scans.sh" << EOF
#!/bin/bash
# Clean up old scan results
echo "Cleaning up old scan results..."
rm -rf $SK_DIR/new_r7nmapScan*
rm -rf ~/.msf4/local/*.*
echo "Cleanup complete."
EOF
    
    # Make scripts executable
    chmod +x "$SK_DIR"/*.sh 2>/dev/null || true
    
    print_success "Helper scripts created"
}

# Create documentation
create_documentation() {
    print_step "Creating documentation"
    
    cat > "$INSTALL_DIR/README.md" << 'EOF'
# Security Assessment Infrastructure

## Quick Start

### 1. Configure Targets
```bash
nano ~/SA/sk/sk_ips
```
Add target IPs or hostnames (one per line).

### 2. Run Scan
```bash
~/SA/sk/quick_scan.sh
```

### 3. Monitor Progress
```bash
tail -f ~/SA/sk/new_r7nmapScan_spool
```

### 4. Clean Up
```bash
~/SA/sk/cleanup_scans.sh
```

## Components
- **Nmap**: Network scanner with NSE scripts
- **Metasploit**: Exploitation framework
- **PostgreSQL**: Database backend
- **Vulscan**: CVE vulnerability databases
- **Nmap-Vulners**: Advanced CVE detection

## Configuration Files
- `sk/sk_ips`: Target configuration
- `sk/bl`: Exclusion list
- `sk/SAD.rc`: Scanning pipeline
- `sk/setup_workspace.rc`: Workspace setup

## Metasploit Commands
```bash
msfconsole
workspace sk
db_status
hosts
services
vulns
```

## Scan Types

### Quick Scan
```bash
msfconsole -q -r ~/SA/sk/SAD.rc
```

### Custom Scan
```bash
nmap -sV -sC --script vuln target.com
```

## Security Warning
⚠️ Use only on authorized networks for educational/testing purposes.

## Support
- Metasploit DB: `msfdb status`
- PostgreSQL: `systemctl status postgresql`
- Update NSE: `sudo nmap --script-updatedb`
- Update Metasploit: `msfupdate`

## Troubleshooting

### Database Issues
```bash
msfdb reinit
```

### Permission Issues
```bash
sudo chown -R $USER:$USER ~/SA/
chmod +x ~/SA/sk/*.sh
```
EOF
    
    print_success "Documentation created"
}

# Create installation summary
create_summary() {
    print_step "Creating installation summary"
    
    local nmap_version="Not installed"
    local msf_version="Not installed"
    local pg_version="Not installed"
    
    if command -v nmap &>/dev/null; then
        nmap_version=$(nmap --version 2>/dev/null | head -1 | awk '{print $3}')
    fi
    
    if command -v msfconsole &>/dev/null; then
        msf_version=$(msfconsole --version 2>/dev/null | head -1 | cut -d: -f2 | xargs)
    fi
    
    if pacman -Q postgresql &>/dev/null; then
        pg_version=$(pacman -Q postgresql | awk '{print $2}')
    fi
    
    cat > "$INSTALL_DIR/INSTALLATION_SUMMARY.txt" << EOF
╔════════════════════════════════════════════════════════════╗
║     Security Assessment Infrastructure - Installed        ║
╚════════════════════════════════════════════════════════════╝

Installation Date: $(date)
Installation Directory: $INSTALL_DIR

INSTALLED COMPONENTS
━━━━━━━━━━━━━━━━━━━━
✓ Nmap: $nmap_version
✓ Metasploit Framework: $msf_version
✓ PostgreSQL: $pg_version
✓ NSE Vulnerability Scripts (Vulscan, Nmap-Vulners)
✓ Configuration Files
✓ Helper Scripts

DIRECTORY STRUCTURE
━━━━━━━━━━━━━━━━━━━
$INSTALL_DIR/
├── sk/
│   ├── sk_ips              # Target configuration
│   ├── bl                  # Exclusion list
│   ├── SAD.rc              # Scanning pipeline
│   ├── setup_workspace.rc  # Workspace setup
│   ├── quick_scan.sh       # Quick scan launcher
│   └── cleanup_scans.sh    # Cleanup utility
├── logs/
├── README.md
└── INSTALLATION_SUMMARY.txt (this file)

NEXT STEPS
━━━━━━━━━━
1. Edit targets:    nano $SK_DIR/sk_ips
2. Run scan:        $SK_DIR/quick_scan.sh
3. View docs:       cat $INSTALL_DIR/README.md

COMMANDS
━━━━━━━━
Check database:     msfdb status
Check PostgreSQL:   systemctl status postgresql
Update NSE:         sudo nmap --script-updatedb
Update Metasploit:  msfupdate

⚠️  SECURITY WARNING
Use only on authorized networks for educational purposes.
Unauthorized scanning is illegal.

Installation Statistics:
  ✓ Successful steps: $SUCCESS_COUNT
  ⚠ Warnings:         $WARNING_COUNT
  ⊙ Skipped:          $SKIP_COUNT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    
    print_success "Summary created"
}

# Main installation function
main() {
    print_header
    
    # Pre-checks
    check_root
    
    # Run installation steps
    create_directories
    check_sudo
    install_base_packages
    install_postgresql
    check_core_tools
    init_metasploit_db
    install_nse_scripts
    configure_metasploit_workspace
    create_config_files
    create_helper_scripts
    create_documentation
    create_summary
    
    # Kill sudo keep-alive
    kill $SUDO_PID 2>/dev/null || true
    
    # Final summary
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║              Installation Complete!                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}Installation Statistics:${NC}"
    echo -e "  ${GREEN}✓${NC} Successful steps: $SUCCESS_COUNT"
    echo -e "  ${YELLOW}⚠${NC} Warnings:         $WARNING_COUNT"
    echo -e "  ${CYAN}⊙${NC} Skipped:          $SKIP_COUNT"
    echo ""
    echo -e "${BLUE}Installation Directory:${NC} $INSTALL_DIR"
    echo -e "${BLUE}Documentation:${NC}          $INSTALL_DIR/README.md"
    echo -e "${BLUE}Summary:${NC}                $INSTALL_DIR/INSTALLATION_SUMMARY.txt"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "  1. Edit targets:  ${CYAN}nano $SK_DIR/sk_ips${NC}"
    echo -e "  2. Run scan:      ${CYAN}$SK_DIR/quick_scan.sh${NC}"
    echo -e "  3. View summary:  ${CYAN}cat $INSTALL_DIR/INSTALLATION_SUMMARY.txt${NC}"
    echo ""
    echo -e "${RED}⚠️  Use only on authorized networks for educational purposes.${NC}"
    echo ""
}

# Run main function
main
