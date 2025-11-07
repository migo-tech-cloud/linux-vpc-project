> **Purpose:** Troubleshooting and teardown reference.


# 🧯 Runbook: Troubleshooting and Cleanup

## Common Issues

### 1. Namespace not found

Run:
sudo ip netns list

If the namespace is missing, recreate it using:

./vpcctl add-subnet vpc1 public 10.0.1.0/24 public

### 2. Bridge already exists
If a VPC was deleted partially, clean up manually:

sudo ip link del vpc1-br0

sudo iptables -t nat -F

### 3. No Internet Access from Public Subnet

Ensure NAT is enabled:

sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o eth0 -j MASQUERADE

sudo sysctl -w net.ipv4.ip_forward=1

### 4. Permission Errors

All commands that touch networking need sudo.

### 5. Cleanup Everything

./scripts/delete_vpc.sh vpc1

sudo iptables -t nat -F

sudo ip netns list | awk '{print $1}' | xargs -n1 sudo ip netns del

## ✅ Verification Commands

ip link show type bridge

ip netns list

sudo iptables -t nat -L -n -v