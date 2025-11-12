#!/bin/bash
# create_vpc2.sh
# Usage: bash create_vpc2.sh <VPC_NAME> <HOST_INTERFACE>

VPC_NAME=${1:-Migo-vpc-2}
HOST_IF=${2:-enX0}

# Subnet CIDRs
PUB_CIDR="10.1.1.2/16"
PRIV_CIDR="10.1.2.2/16"
BRIDGE_IP="10.1.0.1/16"

# Unique veth names for vpc2
VETH_PUB="veth-pub2"
VETH_PUB_BR="veth-pub-br2"
VETH_PRIV="veth-priv2"
VETH_PRIV_BR="veth-priv-br2"
BRIDGE_NAME="vpc2-br0"

echo "🔹 Creating VPC: $VPC_NAME"

# Cleanup if already exists
ip link delete $BRIDGE_NAME type bridge 2>/dev/null
ip netns delete ${VPC_NAME}-public 2>/dev/null
ip netns delete ${VPC_NAME}-private 2>/dev/null

# Create bridge
ip link add $BRIDGE_NAME type bridge
ip addr add $BRIDGE_IP dev $BRIDGE_NAME
ip link set $BRIDGE_NAME up

# Create namespaces
ip netns add ${VPC_NAME}-public
ip netns add ${VPC_NAME}-private

# Create veth pairs
ip link add $VETH_PUB type veth peer name $VETH_PUB_BR
ip link add $VETH_PRIV type veth peer name $VETH_PRIV_BR

# Attach veths to namespaces
ip link set $VETH_PUB netns ${VPC_NAME}-public
ip link set $VETH_PRIV netns ${VPC_NAME}-private

# Attach other ends to bridge
ip link set $VETH_PUB_BR master $BRIDGE_NAME
ip link set $VETH_PRIV_BR master $BRIDGE_NAME

# Bring interfaces up
ip link set $VETH_PUB_BR up
ip link set $VETH_PRIV_BR up
ip -n ${VPC_NAME}-public link set $VETH_PUB up
ip -n ${VPC_NAME}-private link set $VETH_PRIV up

# Assign IPs
ip -n ${VPC_NAME}-public addr add $PUB_CIDR dev $VETH_PUB
ip -n ${VPC_NAME}-private addr add $PRIV_CIDR dev $VETH_PRIV

# Add default routes via bridge
ip -n ${VPC_NAME}-public route add default via ${BRIDGE_IP%/*} 2>/dev/null || true
ip -n ${VPC_NAME}-private route add default via ${BRIDGE_IP%/*} 2>/dev/null || true

# Enable IP forwarding and NAT for public subnet
sysctl -w net.ipv4.ip_forward=1 >/dev/null
iptables -t nat -A POSTROUTING -s ${PUB_CIDR%/*} -o $HOST_IF -j MASQUERADE

echo "✅ VPC $VPC_NAME successfully created!"
echo "Bridge IP: $BRIDGE_IP"
echo "Public Subnet IP: $PUB_CIDR"
echo "Private Subnet IP: $PRIV_CIDR"
echo "Host Interface: $HOST_IF"



