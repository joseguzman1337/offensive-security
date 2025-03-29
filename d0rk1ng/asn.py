#!/usr/bin/env python3

import csv
import os
import sys

import shodan

# Retrieve Shodan API key from environment variables
SHODAN_API_KEY = os.getenv("SHODAN_API_KEY")

# Function to retrieve internal networks associated with an ASN


def get_internal_networks(asn):
    if not SHODAN_API_KEY:
        print("Error: Shodan API key not found in environment variables.")
        sys.exit(1)

    # Create a Shodan API object
    api = shodan.Shodan(SHODAN_API_KEY)

    try:
        # Search for IP addresses associated with the ASN
        results = api.search(f"asn:{asn}")
        internal_networks = []
        for result in results["matches"]:
            ip = result["ip_str"]
            domains = result.get("domains", [])
            internal_networks.append((asn, ip, ",".join(domains)))
        return internal_networks
    except shodan.APIError as e:
        print("Error:", e)
        sys.exit(1)


# Function to extract unique domains from DNS Resolution and remove duplicates


def extract_unique_domains(dns_resolution):
    domains = set()
    for domain_list in dns_resolution.split(","):
        for domain in domain_list.split():
            domains.add(domain.strip())  # Remove leading/trailing whitespace
    return "\n".join(domains)


# Function to write results to a CSV file


def write_to_csv(filename, data):
    with open(filename, mode="w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(["ASN", "Internal IP", "DNS Resolution", "Domains"])

        for asn, internal_ip, dns_resolution in data:
            unique_domains = extract_unique_domains(dns_resolution)
            writer.writerow([asn, internal_ip, dns_resolution, unique_domains])


if __name__ == "__main__":
    asn = sys.argv[1] if len(sys.argv) > 1 else None

    if not asn:
        print("Error: Please provide the ASN as a command-line argument.")
        sys.exit(1)

    internal_networks = get_internal_networks(asn)

    filename = f"{asn}_resolution.csv"
    write_to_csv(filename, internal_networks)

    print(f"Results have been saved to {filename}")
