import ipaddress
import socket
import threading

import boto3
from ports import ports_to_open

# --- Global Variables and Aliases ---
ec2 = None  # Initialize ec2 client globally
dry_run = False  # Set dry_run globally

# Global dictionary to store reachability test results
port_reachability_results = {}


def test_port_reachability(instance_ip, port, protocol, results):
    """Tests if a specific port is reachable from the internet."""
    try:
        if protocol == "tcp":
            with socket.create_connection((instance_ip, port), timeout=5) as sock:
                results[(port, protocol)] = True
        elif protocol == "udp":
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
                sock.settimeout(5)
                sock.sendto(b"", (instance_ip, port))
                try:
                    sock.recvfrom(1024)
                    results[(port, protocol)] = True
                except socket.timeout:
                    results[(port, protocol)] = False
        else:
            results[(port, protocol)] = False
    except Exception as e:
        print(f"Error testing reachability for {instance_ip}:{port}/{protocol}: {e}")
        results[(port, protocol)] = False


def add_inbound_rules_to_security_groups(region_name, instance_ids, allowed_cidrs):
    """
    Adds inbound rules to the security groups of specified EC2 instances.
    Handles RulesPerSecurityGroupLimitExceeded by consolidating rules or
    creating a new security group.
    Adds exception handling for creating duplicate security groups.
    Identifies and removes rules that allow traffic from an Internet Gateway on specific TCP ports.

    Args:
        region_name: The AWS region where the instances are located.
        instance_ids: A list of EC2 instance IDs.
        allowed_cidrs: A list of allowed source CIDR ranges.
    """

    global ec2
    ec2 = boto3.client("ec2", region_name=region_name)

    try:
        # Get information about the instances
        response = ec2.describe_instances(InstanceIds=instance_ids)

        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                instance_id = instance["InstanceId"]
                instance_ip = instance.get(
                    "PublicIpAddress"
                )  # Get the public IP if available
                print(f"Processing instance: {instance_id} (Public IP: {instance_ip})")

                # Get the security groups associated with the instance
                security_groups = instance["SecurityGroups"]

                for sg in security_groups:
                    sg_id = sg["GroupId"]
                    sg_name = sg["GroupName"]
                    print(f"  Processing security group: {sg_name} ({sg_id})")

                    # Describe existing inbound rules for the security group
                    sg_response = ec2.describe_security_group_rules(
                        Filters=[{"Name": "group-id", "Values": [sg_id]}]
                    )

                    existing_rules = sg_response["SecurityGroupRules"]

                    # Test port reachability before modifying rules
                    if instance_ip:
                        threads = []
                        for port_info in ports_to_open:
                            port = port_info["Port"]
                            protocol = port_info["Protocol"]
                            if isinstance(port, list):
                                for p in range(port[0], port[1] + 1):
                                    thread = threading.Thread(
                                        target=test_port_reachability,
                                        args=(
                                            instance_ip,
                                            p,
                                            protocol,
                                            port_reachability_results,
                                        ),
                                    )
                                    threads.append(thread)
                                    thread.start()
                            else:
                                thread = threading.Thread(
                                    target=test_port_reachability,
                                    args=(
                                        instance_ip,
                                        port,
                                        protocol,
                                        port_reachability_results,
                                    ),
                                )
                                threads.append(thread)
                                thread.start()

                        for thread in threads:
                            thread.join()

                    # Identify and remove rules allowing traffic from an Internet Gateway on specific TCP ports
                    rules_to_remove = []
                    for rule in existing_rules:
                        if rule["IpProtocol"] == "tcp" or rule["IpProtocol"] == "udp":
                            port_range = (
                                list(range(rule["FromPort"], rule["ToPort"] + 1))
                                if rule["FromPort"] != rule["ToPort"]
                                else [rule["FromPort"]]
                            )
                            for port in port_range:
                                if (
                                    (port, rule["IpProtocol"])
                                    in port_reachability_results
                                    and port_reachability_results[
                                        (port, rule["IpProtocol"])
                                    ]
                                ):
                                    if (
                                        "CidrIpv4" in rule
                                        and rule["CidrIpv4"] == "0.0.0.0/0"
                                    ):
                                        rules_to_remove.append(
                                            rule["SecurityGroupRuleId"]
                                        )

                    if rules_to_remove:
                        try:
                            ec2.revoke_security_group_ingress(
                                GroupId=sg_id,
                                SecurityGroupRuleIds=rules_to_remove,
                                DryRun=dry_run,
                            )
                            for rule_id in rules_to_remove:
                                print(
                                    f"    Removed rule allowing traffic from 0.0.0.0/0 on {rule['IpProtocol']} port in security group {sg_name} ({sg_id})"
                                )
                        except Exception as e:
                            print(f"    Error removing rule: {e}")

                    # Track the rules that need to be added
                    rules_to_add = []

                    # Add inbound rules for each port and CIDR range
                    for port_info in ports_to_open:
                        port = port_info["Port"]
                        protocol = port_info["Protocol"]

                        for cidr in allowed_cidrs:
                            # Check if a rule already exists
                            rule_exists = False
                            if isinstance(port, list):  # Handle port ranges
                                rule_exists = any(
                                    rule["IpProtocol"] == protocol
                                    and rule["FromPort"] <= port[0]
                                    and rule["ToPort"] >= port[1]
                                    and rule["CidrIpv4"] == cidr
                                    for rule in existing_rules
                                )
                            else:  # Handle single ports
                                rule_exists = any(
                                    rule["IpProtocol"] == protocol
                                    and rule["FromPort"] == port
                                    and rule["ToPort"] == port
                                    and rule["CidrIpv4"] == cidr
                                    for rule in existing_rules
                                )

                            if not rule_exists:
                                if isinstance(port, list):  # Handle port ranges
                                    rules_to_add.append(
                                        {
                                            "IpProtocol": protocol,
                                            "FromPort": port[0],
                                            "ToPort": port[1],
                                            "IpRanges": [{"CidrIp": cidr}],
                                        }
                                    )
                                else:  # Handle single ports
                                    rules_to_add.append(
                                        {
                                            "IpProtocol": protocol,
                                            "FromPort": port,
                                            "ToPort": port,
                                            "IpRanges": [{"CidrIp": cidr}],
                                        }
                                    )

                    # Try to add the rules in a single batch
                    if rules_to_add:
                        try:
                            ec2.authorize_security_group_ingress(
                                GroupId=sg_id,
                                IpPermissions=rules_to_add,
                                DryRun=dry_run,
                            )
                            for rule in rules_to_add:
                                if (
                                    isinstance(rule["FromPort"], int)
                                    and rule["FromPort"] == rule["ToPort"]
                                ):
                                    print(
                                        f"    Added rule: {rule['IpProtocol']}/{rule['FromPort']} from {rule['IpRanges'][0]['CidrIp']} to {sg_name} ({sg_id})"
                                    )
                                else:
                                    print(
                                        f"    Added rule: {rule['IpProtocol']}/{rule['FromPort']}-{rule['ToPort']} from {rule['IpRanges'][0]['CidrIp']} to {sg_name} ({sg_id})"
                                    )

                        except ec2.exceptions.ClientError as e:
                            if (
                                e.response["Error"]["Code"]
                                == "RulesPerSecurityGroupLimitExceeded"
                            ):
                                print(
                                    f"    Error: RulesPerSecurityGroupLimitExceeded for {sg_name} ({sg_id})."
                                )

                                # Consolidate rules for the specified ports
                                consolidated_rules = consolidate_rules(
                                    rules_to_add, ports_to_open
                                )

                                # Attempt to add consolidated rules
                                try:
                                    ec2.authorize_security_group_ingress(
                                        GroupId=sg_id,
                                        IpPermissions=consolidated_rules,
                                        DryRun=dry_run,
                                    )
                                    for rule in consolidated_rules:
                                        if (
                                            isinstance(rule["FromPort"], int)
                                            and rule["FromPort"] == rule["ToPort"]
                                        ):
                                            print(
                                                f"    Added consolidated rule: {rule['IpProtocol']}/{rule['FromPort']} to {sg_name} ({sg_id})"
                                            )
                                        else:
                                            print(
                                                f"    Added consolidated rule: {rule['IpProtocol']}/{rule['FromPort']}-{rule['ToPort']} to {sg_name} ({sg_id})"
                                            )

                                except ec2.exceptions.ClientError as e:
                                    if (
                                        e.response["Error"]["Code"]
                                        == "RulesPerSecurityGroupLimitExceeded"
                                    ):
                                        print(
                                            f"    Error: RulesPerSecurityGroupLimitExceeded even after consolidation for {sg_name} ({sg_id})."
                                        )
                                        # Create a new security group
                                        new_sg_id = create_new_security_group(
                                            ec2,
                                            sg_name,
                                            instance["VpcId"],
                                            consolidated_rules,
                                            allowed_cidrs,
                                            sg_id,
                                        )

                                        if new_sg_id:
                                            print(
                                                f"    Created new security group: {new_sg_id}"
                                            )

                                            # Attach the new security group to the instance
                                            current_group_ids = [
                                                sg["GroupId"] for sg in security_groups
                                            ]
                                            if new_sg_id not in current_group_ids:
                                                ec2.modify_instance_attribute(
                                                    InstanceId=instance_id,
                                                    Groups=(
                                                        current_group_ids + [new_sg_id]
                                                    ),
                                                    DryRun=dry_run,
                                                )
                                                print(
                                                    f"    Attached new security group {new_sg_id} to instance {instance_id}"
                                                )
                                            else:
                                                print(
                                                    f"    Security group {new_sg_id} is already attached to instance {instance_id}"
                                                )

                                    else:
                                        print(f"    An unexpected error occurred: {e}")
                            else:
                                print(f"    An unexpected error occurred: {e}")

    except Exception as e:
        print(f"An error occurred: {e}")


def consolidate_rules(rules, ports_to_open):
    """Consolidates rules for the same port into a single rule with multiple CIDR ranges."""
    consolidated_rules = []
    for port_info in ports_to_open:
        port = port_info["Port"]
        protocol = port_info["Protocol"]

        # Collect CIDR ranges for the current port and protocol
        cidr_ranges = {}
        for rule in rules:
            if isinstance(port, list):  # Handle port ranges
                if (
                    rule["FromPort"] == port[0]
                    and rule["ToPort"] == port[1]
                    and rule["IpProtocol"] == protocol
                ):
                    sg_id = rule.get("SecurityGroupId", "default")
                    if sg_id not in cidr_ranges:
                        cidr_ranges[sg_id] = set()
                    cidr_ranges[sg_id].update([r["CidrIp"] for r in rule["IpRanges"]])
            else:  # Handle single ports
                if rule["FromPort"] == port and rule["IpProtocol"] == protocol:
                    sg_id = rule.get("SecurityGroupId", "default")
                    if sg_id not in cidr_ranges:
                        cidr_ranges[sg_id] = set()
                    cidr_ranges[sg_id].update([r["CidrIp"] for r in rule["IpRanges"]])

        # Create consolidated rules for each security group
        for sg_id, cidrs in cidr_ranges.items():
            if isinstance(port, list):  # Handle port ranges
                consolidated_rules.append(
                    {
                        "IpProtocol": protocol,
                        "FromPort": port[0],
                        "ToPort": port[1],
                        "IpRanges": [{"CidrIp": cidr} for cidr in cidrs],
                    }
                )
            else:  # Handle single ports
                consolidated_rules.append(
                    {
                        "IpProtocol": protocol,
                        "FromPort": port,
                        "ToPort": port,
                        "IpRanges": [{"CidrIp": cidr} for cidr in cidrs],
                    }
                )

    return consolidated_rules


def create_new_security_group(
    ec2, original_sg_name, vpc_id, rules, allowed_cidrs, original_sg_id
):
    """Creates a new security group and adds the specified rules. Handles duplicate group name error."""
    new_sg_name = f"{original_sg_name}-extended"

    # Check for existing security groups with the '-extended' suffix
    existing_sgs = ec2.describe_security_groups(
        Filters=[{"Name": "vpc-id", "Values": [vpc_id]}]
    )["SecurityGroups"]
    count = 1
    while any(sg["GroupName"] == new_sg_name for sg in existing_sgs):
        new_sg_name = f"{original_sg_name}-extended-{count}"
        count += 1

    try:
        # Create the new security group with the updated name
        response = ec2.create_security_group(
            GroupName=new_sg_name,
            Description=f"Extended rules for {original_sg_name}",
            VpcId=vpc_id,
            DryRun=dry_run,
        )
        new_sg_id = response["GroupId"]
        print(f"    Created new security group: {new_sg_id} ({new_sg_name})")

        # Add the rules to the new security group
        ec2.authorize_security_group_ingress(
            GroupId=new_sg_id, IpPermissions=rules, DryRun=dry_run
        )
        print(
            f"    Added consolidated rules to the new security group: {new_sg_id} ({new_sg_name})"
        )

        return new_sg_id

    except ec2.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "InvalidGroup.Duplicate":
            print(
                f"    Error creating new security group: Security group '{new_sg_name}' already exists."
            )

            # Find the existing security group with the updated name
            sg_response = ec2.describe_security_groups(
                Filters=[
                    {"Name": "group-name", "Values": [new_sg_name]},
                    {"Name": "vpc-id", "Values": [vpc_id]},
                ]
            )

            if sg_response["SecurityGroups"]:
                existing_sg = sg_response["SecurityGroups"][0]
                print(
                    f"    Existing security group with name '{new_sg_name}' found: {existing_sg['GroupId']}"
                )
                return existing_sg["GroupId"]

        else:
            print(f"    Error creating new security group: {e}")
            return None


# --- Configuration ---
region_name = "us-west-2"  # Replace with your AWS region
instance_ids = [
    "i-",  # pdc1
    "i-",  # pdc7
    "i-",  # pdc6
    # Add more instance IDs if needed
]
allowed_cidrs = [
    "10.1.65.0/24",
    "10.100.20.0/24",
    "10.100.200.0/24",
    "10.100.30.0/24",
    "10.20.0.0/24",
    "10.20.11.0/24",
    "10.20.31.0/24",
    "10.20.33.0/24",
    "10.20.38.0/24",
    "10.20.48.0/24",
    "10.20.49.0/24",
    "10.20.51.0/24",
    "10.50.0.0/24",
    "10.50.3.0/24",
    "10.50.4.0/24",
    "10.50.5.0/24",
    "10.50.6.0/24",
    "172.16.113.0/24",
    "172.16.129.0/24",
    "172.16.34.0/24",
    "172.16.64.0/24",
    "172.16.65.0/24",
    "172.16.66.0/24",
    "172.16.67.0/24",
    "172.16.68.0/24",
    "172.16.69.0/24",
    "172.16.89.0/24",
    "172.30.0.0/24",
    "172.30.15.0/24",
    "172.30.42.0/24",
    # Add more CIDR ranges if needed
]

# --- Run the function ---
add_inbound_rules_to_security_groups(region_name, instance_ids, allowed_cidrs)
