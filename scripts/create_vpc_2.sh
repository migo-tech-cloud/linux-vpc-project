#!/bin/bash
# Usage: ./create_vpc_2.sh <VPC_NAME> <HOST_IF>
VPC_NAME=$1
HOST_IF=$2

set -e

BRIDGE="${VPC_NAME}-br0"

echo "🔹 Creating VPC: $VPC_NAME"
sudo ip link add "$BRIDGE" type bridge
sudo ip addr add 10.1.0.1/16 dev "$BRIDGE"
sudo ip link set "$BRIDGE" up

# Create network namespaces
sudo ip netns add "${VPC_NAME}-public"
sudo ip netns add "${VPC_NAME}-private"

# Create veth pairs
sudo ip link add veth2-pub type veth peer name veth2-pub-br
sudo ip link add veth2-priv type veth peer name veth2-priv-br

# Attach veth ends to namespaces
sudo ip link set veth2-pub netns "${VPC_NAME}-public"
sudo ip link set veth2-priv netns "${VPC_NAME}-private"

# Attach peer ends to bridge
sudo ip link set veth2-pub-br master "$BRIDGE"
sudo ip link set veth2-priv-br master "$BRIDGE"
sudo ip link set veth2-pub-br up
sudo ip link set veth2-priv-br up

# Assign IP addresses in namespaces
sudo ip -n "${VPC_NAME}-public" addr add 10.1.1.2/16 dev veth2-pub
sudo ip -n "${VPC_NAME}-private" addr add 10.1.2.2/16 dev veth2-priv

# Bring veths up
sudo ip -n "${VPC_NAME}-public" link set veth2-pub up
sudo ip -n "${VPC_NAME}-private" link set veth2-priv up

# Enable IP forwarding
sudo sysctl -w net.ipv4.ip_forward=1

# Set up NAT for Internet (exclude peering later)
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 ! -d 10.0.0.0/16 -o "$HOST_IF" -j MASQUERADE

echo "✅ VPC $VPC_NAME created successfully!"










