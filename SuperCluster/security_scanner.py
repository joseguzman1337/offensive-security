# security_scanner.py
from mpi4py import MPI
import nmap
import requests
import json
from datetime import datetime

class DistributedSecurityScanner:
    def __init__(self):
        self.comm = MPI.COMM_WORLD
        self.rank = self.comm.Get_rank()
        self.size = self.comm.Get_size()
        self.nm = nmap.PortScanner()
        
    def scan_network_range(self, network_range):
        """Distributed network scanning"""
        if self.rank == 0:
            # Master node divides work
            ip_list = self.generate_ip_list(network_range)
            chunks = self.divide_chunks(ip_list, self.size)
        else:
            chunks = None
            
        # Scatter work to workers
        my_chunk = self.comm.scatter(chunks, root=0)
        
        results = []
        for ip in my_chunk:
            scan_result = self.scan_host(ip)
            if scan_result:
                results.append(scan_result)
        
        # Gather results
        all_results = self.comm.gather(results, root=0)
        
        if self.rank == 0:
            return self.aggregate_results(all_results)
        return None
    
    def scan_host(self, ip):
        """Individual host scan"""
        try:
            print(f"[Rank {self.rank}] Scanning {ip}")
            scan_data = self.nm.scan(hosts=ip, arguments='-sV -O -T4')
            return {
                'ip': ip,
                'status': 'up' if ip in scan_data['scan'] else 'down',
                'ports': scan_data['scan'][ip]['tcp'] if ip in scan_data['scan'] else {},
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            return {'ip': ip, 'error': str(e), 'status': 'error'}

# Run scanner
if __name__ == "__main__":
    scanner = DistributedSecurityScanner()
    if MPI.COMM_WORLD.Get_rank() == 0:
        print(f"Starting distributed scan with {MPI.COMM_WORLD.Get_size()} nodes")
    
    # Example: Scan local network
    results = scanner.scan_network_range("192.168.1.0/24")
    
    if results and MPI.COMM_WORLD.Get_rank() == 0:
        with open('scan_results.json', 'w') as f:
            json.dump(results, f, indent=2)
        print(f"Scan complete. Found {len(results)} hosts.")