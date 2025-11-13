#!/bin/bash
# Usage: ./create_vpc_1.sh Migo-vpc-1 enX0

VPC_NAME=$1
HOST_IFACE=$2

BRIDGE_NAME="${VPC_NAME}-br0"
PUB_NS="${VPC_NAME}-public"
PRIV_NS="${VPC_NAME}-private"

echo "🔹 Creating VPC: $VPC_NAME"

# Create network namespaces
sudo ip netns add $PUB_NS
sudo ip netns add $PRIV_NS

# Create bridge
sudo ip link add name $BRIDGE_NAME type bridge
sudo ip addr add 10.0.0.1/16 dev $BRIDGE_NAME
sudo ip link set $BRIDGE_NAME up

# Create veth pairs
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# Attach veth to namespaces
sudo ip link set veth-pub netns $PUB_NS
sudo ip link set veth-priv netns $PRIV_NS

# Attach veth to bridge
sudo ip link set veth-pub-br master $BRIDGE_NAME
sudo ip link set veth-priv-br master $BRIDGE_NAME

# Bring interfaces up
sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up
sudo ip -n $PUB_NS link set veth-pub up
sudo ip -n $PRIV_NS link set veth-priv up

# Assign IPs
sudo ip -n $PUB_NS addr add 10.0.1.2/16 dev veth-pub
sudo ip -n $PRIV_NS addr add 10.0.2.2/16 dev veth-priv

# Enable IP forwarding 
sudo sysctl -w net.ipv4.ip_forward=1

# Set default route inside public namespace
sudo ip netns exec ${VPC_NAME}-public ip route add default via $BRIDGE_IP

# Apply NAT/masquerade for internet access
sudo iptables -t nat -A POSTROUTING -s $SUBNET_PUBLIC -o $HOST_IFACE -j MASQUERADE

echo "✅ VPC $VPC_NAME successfully created!"
echo "Bridge IP: 10.0.0.1/16"
echo "Public Subnet IP: 10.0.1.2/16"
echo "Private Subnet IP: 10.0.2.2/16"
echo "Host Interface: $HOST_IFACE"














