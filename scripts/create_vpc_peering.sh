#!/bin/bash
set -e

echo "============================================================"
echo "🔗 Setting up VPC Peering between VPC1 and VPC2"
echo "============================================================"

HOST_IF="enX0"
VPC1_BR="vpc1-br0"
VPC2_BR="vpc2-br0"

# Create veth pair for peering
sudo ip link add vpc1-peer type veth peer name vpc2-peer
sudo ip link set vpc1-peer master $VPC1_BR
sudo ip link set vpc2-peer master $VPC2_BR
sudo ip link set vpc1-peer up
sudo ip link set vpc2-peer up

# Add routes in each VPC namespace
sudo ip -n vpc1-public route add 10.1.0.0/16 via 10.0.0.1 || true
sudo ip -n vpc1-private route add 10.1.0.0/16 via 10.0.0.1 || true
sudo ip -n vpc2-public route add 10.0.0.0/16 via 10.1.0.1 || true
sudo ip -n vpc2-private route add 10.0.0.0/16 via 10.1.0.1 || true

# Adjust NAT: exclude peering traffic from masquerade
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -d 10.1.0.0/16 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -d 10.0.0.0/16 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 ! -d 10.1.0.0/16 -o $HOST_IF -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 ! -d 10.0.0.0/16 -o $HOST_IF -j MASQUERADE

echo "============================================================"
echo "✅ VPC Peering established!"
echo "Traffic between 10.0.0.0/16 and 10.1.0.0/16 is routed directly."
echo "Internet traffic still goes via NAT on $HOST_IF"
echo "============================================================"
echo "🔹 Test with:"
echo "  sudo ip netns exec vpc1-private ping -c 2 10.1.2.2"
echo "  sudo ip netns exec vpc2-private ping -c 2 10.0.2.2"
echo "============================================================"
