#!/bin/bash
# ============================================================
# create_vpc1.sh — Creates Migo-vpc-1 (public/private + NAT)
# ============================================================

VPC_NAME="Migo-vpc-1"
HOST_IFACE=${2:-"enX0"}

echo "============================================================"
echo "🔹 Creating VPC: $VPC_NAME"
echo "============================================================"

# Clean up any existing VPC with same name
ip netns del ${VPC_NAME}-public 2>/dev/null
ip netns del ${VPC_NAME}-private 2>/dev/null
ip link del ${VPC_NAME}-br0 2>/dev/null

# Create namespaces
sudo ip netns add ${VPC_NAME}-public
sudo ip netns add ${VPC_NAME}-private

# Create bridge
sudo ip link add ${VPC_NAME}-br0 type bridge
sudo ip addr add 10.0.0.1/16 dev ${VPC_NAME}-br0
sudo ip link set ${VPC_NAME}-br0 up

# Create veth pairs
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# Connect to namespaces and bridge
sudo ip link set veth-pub netns ${VPC_NAME}-public
sudo ip link set veth-priv netns ${VPC_NAME}-private
sudo ip link set veth-pub-br master ${VPC_NAME}-br0
sudo ip link set veth-priv-br master ${VPC_NAME}-br0

# Bring up bridge ends
sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# Assign IPs
sudo ip -n ${VPC_NAME}-public addr add 10.0.1.2/16 dev veth-pub
sudo ip -n ${VPC_NAME}-private addr add 10.0.2.2/16 dev veth-priv

# Bring up interfaces
sudo ip -n ${VPC_NAME}-public link set veth-pub up
sudo ip -n ${VPC_NAME}-private link set veth-priv up

# Set default routes
sudo ip -n ${VPC_NAME}-public route add default via 10.0.0.1 2>/dev/null
sudo ip -n ${VPC_NAME}-private route add default via 10.0.0.1 2>/dev/null

# Enable IP forwarding and NAT
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null
sudo iptables -t nat -A POSTROUTING -o ${HOST_IFACE} -j MASQUERADE

echo "✅ $VPC_NAME successfully created!"
echo "Bridge IP: 10.0.0.1/16"
echo "Public Subnet IP: 10.0.1.2/16"
echo "Private Subnet IP: 10.0.2.2/16"
echo "Host Interface: ${HOST_IFACE}"
echo "============================================================"









