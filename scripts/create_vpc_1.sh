#!/bin/bash
# create_migo_vpc_1.sh - Creates Migo-vpc-1 with public/private subnets, bridge, NAT, and routing

VPC_NAME=${1:-Migo-vpc-1}   # default name if not provided
HOST_IFACE=${2:-enX0}       # host network interface
BRIDGE="${VPC_NAME}-br0"

# IP ranges
BRIDGE_IP="10.0.0.1/16"
PUB_IP="10.0.1.2/16"
PRIV_IP="10.0.2.2/16"

# Namespaces
PUB_NS="${VPC_NAME}-public"
PRIV_NS="${VPC_NAME}-private"

echo "🔹 Creating bridge $BRIDGE..."
sudo ip link add "$BRIDGE" type bridge
sudo ip addr add "$BRIDGE_IP" dev "$BRIDGE"
sudo ip link set "$BRIDGE" up

echo "🔹 Creating network namespaces..."
sudo ip netns add "$PUB_NS"
sudo ip netns add "$PRIV_NS"

echo "🔹 Creating veth pairs..."
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# Attach veth pairs to namespaces and bridge
sudo ip link set veth-pub netns "$PUB_NS"
sudo ip link set veth-priv netns "$PRIV_NS"
sudo ip link set veth-pub-br master "$BRIDGE"
sudo ip link set veth-priv-br master "$BRIDGE"

# Bring up bridge-side interfaces
sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# Assign IPs inside namespaces
sudo ip -n "$PUB_NS" addr add "$PUB_IP" dev veth-pub
sudo ip -n "$PRIV_NS" addr add "$PRIV_IP" dev veth-priv

# Bring up namespace interfaces and loopback
sudo ip -n "$PUB_NS" link set veth-pub up
sudo ip -n "$PUB_NS" link set lo up
sudo ip -n "$PRIV_NS" link set veth-priv up
sudo ip -n "$PRIV_NS" link set lo up

# Add default routes via bridge
sudo ip -n "$PUB_NS" route add default via 10.0.0.1 || echo "⚠️ Default route exists"
sudo ip -n "$PRIV_NS" route add default via 10.0.0.1 || echo "⚠️ Default route exists"

# Enable IP forwarding
echo "🔹 Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

# Setup NAT (MASQUERADE) for internet access
echo "🔹 Setting up NAT on $HOST_IFACE..."
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 ! -d 10.1.0.0/16 -o "$HOST_IFACE" -j MASQUERADE

echo "✅ VPC $VPC_NAME successfully created!"
echo "Bridge IP: $BRIDGE_IP"
echo "Public Subnet IP: $PUB_IP"
echo "Private Subnet IP: $PRIV_IP"
echo "Host Interface: $HOST_IFACE"











