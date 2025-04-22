#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
from collections import defaultdict  # Use defaultdict for convenience

import boto3

# --- Argument Parsing ---
parser = argparse.ArgumentParser(
    description="Find EC2 instances associated with specific security groups and display results in a table.",
    epilog="Example: python sg.py sg-xxxxxxxxxxxxxxxxx sg-yyyyyyyyyyyyyyyyy",
)
parser.add_argument(
    "security_group_ids",
    metavar="SECURITY_GROUP_ID",
    nargs="+",
    help="One or more security group IDs (separated by spaces)",
)
args = parser.parse_args()

# Use a set for efficient lookup of input SGs
input_sgs = set(args.security_group_ids)

# --- AWS Interaction ---
# Use a dictionary where keys are SG IDs and values are sets of Instance IDs
# Using defaultdict simplifies adding to the set
instances_by_sg = defaultdict(set)

try:
    ec2 = boto3.client("ec2")
    # We still filter by the input SGs to limit the AWS response
    response = ec2.describe_instances(
        Filters=[
            {
                "Name": "instance.group-id",
                "Values": args.security_group_ids,  # Pass the original list here
            }
        ]
    )

    # --- Process Results ---
    # Iterate through the instances returned by the API call
    if "Reservations" in response:
        for reservation in response["Reservations"]:
            if "Instances" in reservation:
                for instance in reservation["Instances"]:
                    instance_id = instance.get("InstanceId")
                    if not instance_id:  # Skip if instance ID is missing
                        continue

                    # Check which security groups this instance uses
                    if "SecurityGroups" in instance:
                        for sg in instance["SecurityGroups"]:
                            sg_id = sg.get("GroupId")
                            # If this instance's SG is one of the ones we are looking for...
                            if sg_id in input_sgs:
                                # ...add the instance ID to the set for that SG ID
                                instances_by_sg[sg_id].add(instance_id)

except Exception as e:
    print(f"An error occurred interacting with AWS: {e}", file=sys.stderr)
    sys.exit(1)

# --- Output Generation ---
print("\nSecurity Group Usage Report")
print("-" * 60)
# Define column headers - adjust spacing as needed
header = f"{'Security Group':<25} {'Associated Instances':<35}"
print(header)
print("-" * 60)

# Iterate through the *original list* of input security groups to ensure all are reported
# Sort the input list for consistent output order
for sg_id in sorted(args.security_group_ids):
    # Check if we found any instances for this specific SG ID in our results
    if sg_id in instances_by_sg:
        # Get the set of instance IDs, sort them, and join into a string
        instance_list_str = ", ".join(sorted(list(instances_by_sg[sg_id])))
    else:
        # If the SG ID is not a key in our results dict, it means no instances were found using it
        instance_list_str = "None"

    # Print the row, using ljust for basic column alignment
    print(f"{sg_id:<25} {instance_list_str:<35}")

print("-" * 60)
