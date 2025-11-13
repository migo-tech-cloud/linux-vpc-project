#!/bin/bash
# Usage: ./create_vpc_1.sh <VPC_NAME> <HOST_IF>
VPC_NAME=$1
HOST_IF=$2

set -e

BRIDGE="${VPC_NAME}-br0"

echo "🔹 Creating VPC: $VPC_NAME"
sudo ip link add "$BRIDGE" type bridge
sudo ip addr add 10.0.0.1/16 dev "$BRIDGE"
sudo ip link set "$BRIDGE" up

# Create network namespaces
sudo ip netns add "${VPC_NAME}-public"
sudo ip netns add "${VPC_NAME}-private"

# Create veth pairs
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# Attach veth ends to namespaces
sudo ip link set veth-pub netns "${VPC_NAME}-public"
sudo ip link set veth-priv netns "${VPC_NAME}-private"

# Attach peer ends to bridge
sudo ip link set veth-pub-br master "$BRIDGE"
sudo ip link set veth-priv-br master "$BRIDGE"
sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# Assign IP addresses in namespaces
sudo ip -n "${VPC_NAME}-public" addr add 10.0.1.2/16 dev veth-pub
sudo ip -n "${VPC_NAME}-private" addr add 10.0.2.2/16 dev veth-priv

# Bring veths up
sudo ip -n "${VPC_NAME}-public" link set veth-pub up
sudo ip -n "${VPC_NAME}-private" link set veth-priv up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Set up NAT for Internet (exclude peering later)
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 ! -d 10.1.0.0/16 -o "$HOST_IF" -j MASQUERADE

echo "✅ VPC $VPC_NAME created successfully!"












