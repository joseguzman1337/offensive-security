# Security Assessment Infrastructure

## Overview

This infrastructure provides automated security scanning capabilities using Metasploit Framework and Nmap with advanced NSE scripts.

## Directory Structure

```
/home/user/SA/
├── sk/
│   ├── sk_ips          # Target IP addresses/hostnames (one per line)
│   ├── bl              # Blacklist/exclusion IPs (one per line)
│   ├── SAD.rc          # Main Metasploit scanning pipeline
│   ├── setup_workspace.rc  # Workspace configuration script
│   ├── quick_scan.sh   # Quick scan execution
│   └── cleanup_scans.sh    # Clean old scan results
└── README.md
```

## Components Installed

- **Nmap**: Network scanner with 600+ NSE scripts
- **Metasploit Framework 6**: Exploitation framework with database integration
- **PostgreSQL**: Database backend for Metasploit
- **Vulscan NSE**: Vulnerability scanning scripts with CVE databases
- **Nmap-Vulners**: Advanced CVE detection

## Configuration

### Database

- PostgreSQL: Running on port 5432
- Metasploit DB: Initialized at ~/.msf4/db
- Workspace: sk (configured)

### Scan Configuration

- Workspace: sk
- Console Logging: Enabled
- Session Logging: Enabled
- Log Level: 5 (verbose)
- Timestamp Output: Enabled

## Usage

### 1. Configure Targets

Edit target file with IPs or hostnames to scan:

```bash
nano /home/user/SA/sk/sk_ips
```

### 2. Configure Exclusions (Optional)

Add IPs to exclude from scanning:

```bash
nano /home/user/SA/sk/bl
```

### 3. Run Security Scan

```bash
# Method 1: Using helper script
/home/user/SA/sk/quick_scan.sh

# Method 2: Direct Metasploit
msfconsole -r /home/user/SA/sk/SAD.rc

# Method 3: From Metasploit console
msfconsole
resource /home/user/SA/sk/SAD.rc
```

### 4. Monitor Scan Progress

```bash
tail -f /home/user/SA/sk/new_r7nmapScan_sk
```

### 5. View Results

Scan results are saved in multiple formats:

- XML: /home/user/SA/sk/new_r7nmapScan.xml
- Nmap: /home/user/SA/sk/new_r7nmapScan.nmap
- Grepable: /home/user/SA/sk/new_r7nmapScan.gnmap
- Script Kiddie: /home/user/SA/sk/new_r7nmapScan_sk
- Spool: /home/user/SA/sk/new_r7nmapScan_spool

### 6. Clean Up Old Scans

```bash
/home/user/SA/sk/cleanup_scans.sh
```

## Scan Features

The automated pipeline includes:

- Comprehensive OS detection and fingerprinting
- All 65535 TCP ports scanning
- UDP scanning on common ports
- Service version detection
- Vulnerability discovery via CVE databases
- Firewall/IDS evasion techniques
- Network traceroute
- MAC address spoofing support
- Comprehensive NSE script execution

## NSE Scripts Enabled

- auth: Authentication bypass testing
- broadcast: Network broadcast discovery
- brute: Brute force attacks
- discovery: Service/network discovery
- dos: DoS vulnerability detection
- external: External resource queries
- fuzzer: Protocol fuzzing
- intrusive: Invasive testing
- malware: Malware detection
- version: Version detection
- vuln: Vulnerability detection

## Vulnerability Databases

- CVE (cve.csv)
- ExploitDB (exploitdb.csv)
- OpenVAS (openvas.csv)
- OSVDB (osvdb.csv)
- SCIP VulDB (scipvuldb.csv)
- SecurityFocus (securityfocus.csv)
- SecurityTracker (securitytracker.csv)
- X-Force (xforce.csv)

## Metasploit Commands

### Database Management

```
msfconsole
db_status                    # Check database connection
db_rebuild_cache            # Rebuild module cache
workspace -a <name>         # Create workspace
workspace -l                # List workspaces
workspace <name>            # Switch workspace
db_export -f xml <path>     # Export scan results
db_import <path>            # Import scan results
```

### Scan Management

```
db_nmap --resume <xml>      # Resume previous scan
db_nmap --iflist            # Show network interfaces
hosts                       # Show discovered hosts
services                    # Show discovered services
vulns                       # Show discovered vulnerabilities
```

## Security Notes

⚠️ **IMPORTANT**: This infrastructure is designed for:

- Authorized security assessments only
- Educational purposes
- Use only on networks you own or have explicit permission to test

**Unauthorized scanning is illegal and unethical.**

## Services Status

Check service status:

```bash
systemctl status postgresql --no-pager
msfdb status
```

Restart services:

```bash
sudo systemctl restart postgresql
msfdb restart
```

## Troubleshooting

### Database Issues

If Metasploit can't connect to database:

```bash
msfdb reinit
```

### Update NSE Scripts

```bash
sudo nmap --script-updatedb
```

### Update Metasploit

```bash
msfupdate
```

## Advanced Scan Types

### Fast Full Scan (Single Target)

```bash
db_nmap --save --privileged -A -f -sV -sC --script=auth,vuln,vulscan \
  --script-args vulscandb=cve.csv -p443 -T4 target.example.com \
  -oA /home/user/SA/sk/fast_scan
```

### Intense UDP Scan

```bash
db_nmap -sS -sU -T4 -v --traceroute -iL /home/user/SA/sk/sk_ips \
  -oA /home/user/SA/sk/udp_scan
```

### Quick Scan

```bash
db_nmap -T4 --traceroute -iL /home/user/SA/sk/sk_ips \
  -oA /home/user/SA/sk/quick_scan
```

## References

- Nmap: https://nmap.org/
- Metasploit: https://www.metasploit.com/
- Vulscan: https://github.com/scipag/vulscan
- Nmap-Vulners: https://github.com/vulnersCom/nmap-vulners

## License

For authorized security testing only.
