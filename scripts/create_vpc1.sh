#!/bin/bash
# ==============================================
# Create Virtual Private Cloud (VPC1) 
# Author: Owajimimin John
# ==============================================

VPC_NAME="vpc1"
BRIDGE_NAME="${VPC_NAME}-br0"
PUBLIC_NS="${VPC_NAME}-public"
PRIVATE_NS="${VPC_NAME}-private"
HOST_IFACE="enX0"

BRIDGE_IP="10.0.0.1/16"
PUBLIC_IP="10.0.1.2/16"
PRIVATE_IP="10.0.2.2/16"

echo "============================================================"
echo "🚀 Creating Virtual Private Cloud: ${VPC_NAME}"
echo "============================================================"

# --------------------------------------------------------------
# 1️⃣ Clean up any previous configuration
# --------------------------------------------------------------
echo "🔹 Cleaning previous configs..."
sudo ip netns del $PUBLIC_NS 2>/dev/null
sudo ip netns del $PRIVATE_NS 2>/dev/null
sudo ip link del $BRIDGE_NAME 2>/dev/null
sudo ip link del veth-pub 2>/dev/null
sudo ip link del veth-pub-br 2>/dev/null
sudo ip link del veth-priv 2>/dev/null
sudo ip link del veth-priv-br 2>/dev/null

# --------------------------------------------------------------
# 2️⃣ Create the VPC bridge
# --------------------------------------------------------------
echo "🔹 Creating bridge ${BRIDGE_NAME}..."
sudo ip link add $BRIDGE_NAME type bridge
sudo ip addr add $BRIDGE_IP dev $BRIDGE_NAME
sudo ip link set $BRIDGE_NAME up

# --------------------------------------------------------------
# 3️⃣ Create network namespaces
# --------------------------------------------------------------
echo "🔹 Creating namespaces..."
sudo ip netns add $PUBLIC_NS
sudo ip netns add $PRIVATE_NS

# --------------------------------------------------------------
# 4️⃣ Create veth pairs and connect them to bridge & namespaces
# --------------------------------------------------------------
echo "🔹 Creating veth pairs..."
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

sudo ip link set veth-pub netns $PUBLIC_NS
sudo ip link set veth-pub-br master $BRIDGE_NAME

sudo ip link set veth-priv netns $PRIVATE_NS
sudo ip link set veth-priv-br master $BRIDGE_NAME

sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# --------------------------------------------------------------
# 5️⃣ Assign IP addresses and routes
# --------------------------------------------------------------
echo "🔹 Configuring subnet interfaces..."
sudo ip -n $PUBLIC_NS addr flush dev veth-pub 2>/dev/null
sudo ip -n $PRIVATE_NS addr flush dev veth-priv 2>/dev/null

sudo ip -n $PUBLIC_NS addr add $PUBLIC_IP dev veth-pub
sudo ip -n $PRIVATE_NS addr add $PRIVATE_IP dev veth-priv

sudo ip -n $PUBLIC_NS link set veth-pub up
sudo ip -n $PRIVATE_NS link set veth-priv up

echo "🔹 Adding default routes..."
sudo ip -n $PUBLIC_NS route flush table main 2>/dev/null
sudo ip -n $PRIVATE_NS route flush table main 2>/dev/null
sudo ip -n $PUBLIC_NS route add default via 10.0.0.1
sudo ip -n $PRIVATE_NS route add default via 10.0.0.1

# --------------------------------------------------------------
# 6️⃣ Enable IP forwarding & NAT for internet access
# --------------------------------------------------------------
echo "🔹 Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1 >/dev/null

echo "🔹 Setting up NAT on ${HOST_IFACE}..."
sudo iptables -t nat -D POSTROUTING -o $HOST_IFACE -j MASQUERADE 2>/dev/null
sudo iptables -t nat -A POSTROUTING -o $HOST_IFACE -j MASQUERADE

# --------------------------------------------------------------
# ✅ Summary
# --------------------------------------------------------------
echo "============================================================"
echo "✅ VPC ${VPC_NAME} successfully created!"
echo "Bridge IP: ${BRIDGE_IP}"
echo "Public Subnet IP: ${PUBLIC_IP}"
echo "Private Subnet IP: ${PRIVATE_IP}"
echo "Host Interface: ${HOST_IFACE}"
echo "============================================================"
echo "🔹 Verify with:"
echo "  sudo ip netns exec ${PUBLIC_NS} ping -c 2 ${PRIVATE_IP%%/*}"
echo "  sudo ip netns exec ${PUBLIC_NS} ping -c 2 8.8.8.8"
echo "============================================================"

