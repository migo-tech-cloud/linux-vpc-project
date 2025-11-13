## ** `README.md`**

## 🧠 Author

Owajimimin John — DevOps Intern

## This project demonstrates deep Linux networking, isolation, and automation skills.

---

# Linux VPC Project

## Overview
This project recreates a Virtual Private Cloud (VPC) on a single Linux host using network namespaces, veth pairs, bridges, routing tables, and iptables. It simulates:

- Public and private subnets
- Routing between subnets
- NAT gateway for internet access
- VPC isolation and peering
- Security group-like firewall rules

All VPC operations are automated using the `vpcctl.py` CLI tool.

---

## Architecture
Host Interface (enX0)
        │
Linux Bridge (Migo-vpc-1-br0 / Migo-vpc-2-br0)
┌───────────────┐
│               │
Public-NS   Private-NS
10.0.1.2/24 10.0.2.2/24

---

## Project Structure
vpc-project/
├── vpcctl.py
├── config/
│ └── policies.json # Firewall rules
├── scripts/
│ ├── create_migo_vpc_1.sh
│ ├── create_migo_vpc_2.sh
│ ├── delete_vpcs.sh
│ └── apply_firewall.sh
├──logs/
| ├── create.log 
│ └── cleanup.log
├── examples/
│ └── demo.md # Demo instructions
├── README.md
└── runbook.md

---

## CLI Usage

# Make scripts executable
chmod +x scripts/*.sh

# Create VPCs
python3 vpcctl.py create

# Apply firewall/security group rules
python3 vpcctl.py firewall

# Start HTTP server in default namespace (Migo-vpc-1-public)
python3 vpcctl.py start-server

# Stop all HTTP servers
python3 vpcctl.py stop-server

# Establish VPC peering
python3 vpcctl.py peer

# Remove VPC peering
python3 vpcctl.py unpeer

# Delete all VPCs
python3 vpcctl.py delete

## Testing & Validation
Intra-VPC communication

sudo ip netns exec Migo-vpc-1-public ping 10.0.2.2
Public subnet outbound internet

sudo ip netns exec Migo-vpc-1-public ping 8.8.8.8
Private subnet isolation

sudo ip netns exec Migo-vpc-1-private ping 8.8.8.8   # Should fail
Cross-VPC communication via peering

python3 vpcctl.py peer
sudo ip netns exec Migo-vpc-1-public ping 10.1.1.2

## Cleanup

python3 vpcctl.py stop-server

python3 vpcctl.py unpeer

python3 vpcctl.py delete

---

## Notes
- VPC names are hardcoded: Migo-vpc-1 and Migo-vpc-2.

- Host interface should be updated in vpcctl.py if different from enX0.

Firewall rules can be updated in config/policies.json.


