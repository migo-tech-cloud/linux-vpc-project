### ** runbook.md**

# Linux VPC Project - Runbook

## Purpose
Provides operational guidance, troubleshooting steps, and cleanup instructions.

---

## Pre-Requisites
- Linux host (Ubuntu recommended)
- Python 3
- `ip`, `iptables`, `bridge` utilities
- `jq` for parsing JSON policies

---

## Common Commands

### 1. Check namespaces

ip netns list

### 2. Check bridges

ip link show type bridge

### 3. Check routes

ip netns exec Migo-vpc-1-public ip route

### 4. Check iptables rules

ip netns exec Migo-vpc-1-public iptables -L -n

## Troubleshooting
Issue ================================================= Solution
Nexthop invalid gateway =============================== Ensure bridge IP is in the same subnet as namespace IP.
Cannot find veth device ===============================	Ensure create scripts ran successfully; check namespace names.
HTTP server not reachable =============================	Check firewall rules and namespace IPs.

## Cleanup Steps
### Stop servers

python3 vpcctl.py stop-server

### Remove peering

python3 vpcctl.py unpeer

### Delete VPCs

python3 vpcctl.py delete

### Logging

All actions from vpcctl.py are printed to stdout. Redirect to a file if needed:

python3 vpcctl.py create | tee create.log

