#!/bin/bash
# Usage: ./create_vpc1.sh Migo-vpc-1 <host_interface>

VPC_NAME=$1
HOST_IFACE=$2
BRIDGE="${VPC_NAME}-br0"

echo "🔹 Creating VPC: $VPC_NAME"

# Create bridge
sudo ip link add $BRIDGE type bridge
sudo ip addr add 10.0.0.1/16 dev $BRIDGE
sudo ip link set $BRIDGE up

# Create namespaces
sudo ip netns add ${VPC_NAME}-public
sudo ip netns add ${VPC_NAME}-private

# Create veth pairs and connect to bridge
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

sudo ip link set veth-pub netns ${VPC_NAME}-public
sudo ip link set veth-priv netns ${VPC_NAME}-private

sudo ip link set veth-pub-br master $BRIDGE
sudo ip link set veth-priv-br master $BRIDGE

sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# Assign IP addresses inside namespaces
sudo ip -n ${VPC_NAME}-public addr add 10.0.1.2/16 dev veth-pub
sudo ip -n ${VPC_NAME}-private addr add 10.0.2.2/16 dev veth-priv

sudo ip -n ${VPC_NAME}-public link set veth-pub up
sudo ip -n ${VPC_NAME}-private link set veth-priv up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null

# NAT for public subnet
sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o $HOST_IFACE -j MASQUERADE

echo "✅ VPC $VPC_NAME created successfully!"



