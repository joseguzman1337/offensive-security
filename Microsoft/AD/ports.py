# ports.py

ports_to_open = [
    # Remote Access and Management
    {"Port": 3389, "Protocol": "tcp", "Purpose": "RDP (Remote Desktop Protocol)"},
    {"Port": 3389, "Protocol": "udp", "Purpose": "RDP (Remote Desktop Protocol)"},
    {"Port": 5985, "Protocol": "tcp", "Purpose": "WinRM-HTTP (WS-Management)"},
    {"Port": 5986, "Protocol": "tcp", "Purpose": "WinRM-HTTPS (WS-Management)"},
    {"Port": 9389, "Protocol": "tcp", "Purpose": "AD DS Web Services"},
    # File and Printer Sharing
    {"Port": 137, "Protocol": "udp", "Purpose": "NetBIOS Name Service"},
    {"Port": 138, "Protocol": "udp", "Purpose": "NetBIOS Datagram Service"},
    {"Port": 139, "Protocol": "tcp", "Purpose": "NetBIOS Session Service"},
    {"Port": 445, "Protocol": "tcp", "Purpose": "SMB over TCP (CIFS)"},
    # Directory Services (Active Directory, LDAP)
    {"Port": 88, "Protocol": "tcp", "Purpose": "Kerberos"},
    {"Port": 88, "Protocol": "udp", "Purpose": "Kerberos"},
    {"Port": 389, "Protocol": "tcp", "Purpose": "LDAP"},
    {"Port": 389, "Protocol": "udp", "Purpose": "LDAP"},
    {"Port": 464, "Protocol": "tcp", "Purpose": "Kerberos Change/Set Password"},
    {"Port": 464, "Protocol": "udp", "Purpose": "Kerberos Change/Set Password"},
    {"Port": 636, "Protocol": "tcp", "Purpose": "LDAPS (LDAP over SSL/TLS)"},
    {"Port": 3268, "Protocol": "tcp", "Purpose": "Global Catalog"},
    {"Port": 3269, "Protocol": "tcp", "Purpose": "Global Catalog over SSL/TLS"},
    # Domain Name System (DNS)
    {"Port": 53, "Protocol": "tcp", "Purpose": "DNS"},
    {"Port": 53, "Protocol": "udp", "Purpose": "DNS"},
    # Dynamic Host Configuration Protocol (DHCP)
    {"Port": 68, "Protocol": "udp", "Purpose": "DHCP Client"},
    {"Port": 546, "Protocol": "udp", "Purpose": "DHCPv6 Client"},
    # Time Synchronization
    {"Port": 123, "Protocol": "udp", "Purpose": "NTP (Network Time Protocol)"},
    # Remote Procedure Call (RPC)
    {"Port": 135, "Protocol": "tcp", "Purpose": "RPC Endpoint Mapper"},
    {"Port": 135, "Protocol": "udp", "Purpose": "RPC Endpoint Mapper"},
    {"Port": [49152, 65535], "Protocol": "tcp", "Purpose": "Dynamic RPC Ports"},
    # Network Discovery and Service Location
    {
        "Port": 1900,
        "Protocol": "udp",
        "Purpose": "SSDP (Simple Service Discovery Protocol)",
    },
    {"Port": 2869, "Protocol": "tcp", "Purpose": "ICSLAP"},
    {"Port": 3702, "Protocol": "udp", "Purpose": "WS-Discovery"},
    {"Port": 5353, "Protocol": "udp", "Purpose": "mDNS (Multicast DNS)"},
    {
        "Port": 5355,
        "Protocol": "udp",
        "Purpose": "LLMNR (Link-Local Multicast Name Resolution)",
    },
    {"Port": 5357, "Protocol": "tcp", "Purpose": "WSDAPI (Web Services for Devices)"},
    {"Port": 5357, "Protocol": "udp", "Purpose": "WSDAPI (Web Services for Devices)"},
    {"Port": 5358, "Protocol": "tcp", "Purpose": "WSDAPI (Web Services for Devices)"},
    # Other Ports
    {"Port": 554, "Protocol": "tcp", "Purpose": "RTSP (Real Time Streaming Protocol)"},
    {"Port": 554, "Protocol": "udp", "Purpose": "RTSP (Real Time Streaming Protocol)"},
    {
        "Port": [8554, 8558],
        "Protocol": "tcp",
        "Purpose": "RTSP (Real Time Streaming Protocol)",
    },
    {
        "Port": [8554, 8558],
        "Protocol": "udp",
        "Purpose": "RTSP (Real Time Streaming Protocol)",
    },
    {"Port": [5000, 5020], "Protocol": "tcp", "Purpose": "UPnP or other applications"},
    {
        "Port": 7680,
        "Protocol": "tcp",
        "Purpose": "Delivery Optimization (Windows Update P2P)",
    },
    {
        "Port": 10246,
        "Protocol": "tcp",
        "Purpose": "Registered port (application specific)",
    },
    {
        "Port": 10247,
        "Protocol": "tcp",
        "Purpose": "Registered port (application specific)",
    },
    {
        "Port": 17472,
        "Protocol": "tcp",
        "Purpose": "Registered port (application specific)",
    },
    {"Port": 9955, "Protocol": "tcp", "Purpose": "Specific service port"},
    {"Port": 23554, "Protocol": "tcp", "Purpose": "Specific service port"},
    {"Port": 23555, "Protocol": "tcp", "Purpose": "Specific service port"},
    {"Port": 23556, "Protocol": "tcp", "Purpose": "Specific service port"},
    {"Port": 443, "Protocol": "tcp", "Purpose": "IPHTTPS"},
]
