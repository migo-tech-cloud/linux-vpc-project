#!/bin/bash
set -e

echo "============================================================"
echo "🚀 Creating VPC2 (10.1.0.0/16)..."
echo "============================================================"

HOST_IF="enX0"
BRIDGE="vpc2-br0"
PUB_NS="vpc2-public"
PRIV_NS="vpc2-private"

# Create namespaces
sudo ip netns add $PUB_NS
sudo ip netns add $PRIV_NS

# Create bridge
sudo ip link add $BRIDGE type bridge
sudo ip addr add 10.1.0.1/16 dev $BRIDGE
sudo ip link set $BRIDGE up

# veth pairs
sudo ip link add veth2-pub type veth peer name veth2-pub-br
sudo ip link add veth2-priv type veth peer name veth2-priv-br

# Attach one end to namespaces
sudo ip link set veth2-pub netns $PUB_NS
sudo ip link set veth2-priv netns $PRIV_NS

# Attach the other ends to bridge
sudo ip link set veth2-pub-br master $BRIDGE
sudo ip link set veth2-priv-br master $BRIDGE
sudo ip link set veth2-pub-br up
sudo ip link set veth2-priv-br up

# Assign IPs
sudo ip -n $PUB_NS addr add 10.1.1.2/16 dev veth2-pub
sudo ip -n $PRIV_NS addr add 10.1.2.2/16 dev veth2-priv
sudo ip -n $PUB_NS link set veth2-pub up
sudo ip -n $PRIV_NS link set veth2-priv up

# Add routes
sudo ip -n $PUB_NS route add default via 10.1.0.1 || true
sudo ip -n $PRIV_NS route add default via 10.1.0.1 || true

# Enable forwarding + NAT
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -o $HOST_IF -j MASQUERADE

echo "============================================================"
echo "✅ VPC2 successfully created!"
echo "Bridge: $BRIDGE"
echo "Public subnet: 10.1.1.2/16"
echo "Private subnet: 10.1.2.2/16"
echo "============================================================"
