#!/bin/bash
# ============================================================
# create_vpc1.sh — Rebuild VPC1 on Linux
# Author: Owajimimin
# ============================================================

set -e
set -u

# --- CONFIGURATION ---
VPC_NAME="vpc1"
BRIDGE_NAME="${VPC_NAME}-br0"
PUBLIC_NS="${VPC_NAME}-public"
PRIVATE_NS="${VPC_NAME}-private"
BRIDGE_IP="10.0.0.1/16"
PUB_SUBNET_IP="10.0.1.2/24"
PRIV_SUBNET_IP="10.0.2.2/24"
HOST_IF="enX0"   # Change this to your host's main network interface

echo "============================================================"
echo "🛠️  Creating VPC: ${VPC_NAME}"
echo "============================================================"

# --- CLEANUP OLD RESOURCES IF EXIST ---
echo "🔹 Cleaning old resources..."
sudo ip netns del ${PUBLIC_NS} 2>/dev/null || true
sudo ip netns del ${PRIVATE_NS} 2>/dev/null || true
sudo ip link del ${BRIDGE_NAME} 2>/dev/null || true
sudo ip link del veth-pub-br 2>/dev/null || true
sudo ip link del veth-priv-br 2>/dev/null || true

# --- CREATE BRIDGE ---
echo "🔹 Creating bridge ${BRIDGE_NAME}"
sudo ip link add ${BRIDGE_NAME} type bridge
sudo ip addr add ${BRIDGE_IP} dev ${BRIDGE_NAME}
sudo ip link set ${BRIDGE_NAME} up

# --- CREATE NETWORK NAMESPACES ---
echo "🔹 Creating namespaces..."
sudo ip netns add ${PUBLIC_NS}
sudo ip netns add ${PRIVATE_NS}

# --- CREATE VETH PAIRS ---
echo "🔹 Creating veth pairs..."
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# --- ATTACH INTERFACES ---
echo "🔹 Attaching veth interfaces..."
sudo ip link set veth-pub netns ${PUBLIC_NS}
sudo ip link set veth-priv netns ${PRIVATE_NS}
sudo ip link set veth-pub-br master ${BRIDGE_NAME}
sudo ip link set veth-priv-br master ${BRIDGE_NAME}

sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# --- CONFIGURE INTERFACES INSIDE NAMESPACES ---
echo "🔹 Configuring IPs inside namespaces..."
sudo ip -n ${PUBLIC_NS} addr add ${PUB_SUBNET_IP} dev veth-pub
sudo ip -n ${PRIVATE_NS} addr add ${PRIV_SUBNET_IP} dev veth-priv
sudo ip -n ${PUBLIC_NS} link set veth-pub up
sudo ip -n ${PRIVATE_NS} link set veth-priv up

# --- ENSURE BRIDGE IS UP BEFORE ROUTES ---
echo "🔹 Ensuring ${BRIDGE_NAME} is reachable..."
sleep 1
sudo ip link set ${BRIDGE_NAME} up

# --- ADD DEFAULT ROUTES SAFELY ---
echo "🔹 Adding default routes safely..."
if ! sudo ip -n ${PUBLIC_NS} route show | grep -q "default via 10.0.0.1"; then
  sudo ip -n ${PUBLIC_NS} route add default via 10.0.0.1 dev veth-pub || true
fi

if ! sudo ip -n ${PRIVATE_NS} route show | grep -q "default via 10.0.0.1"; then
  sudo ip -n ${PRIVATE_NS} route add default via 10.0.0.1 dev veth-priv || true
fi

# --- ENABLE IP FORWARDING ---
echo "🔹 Enabling IP forwarding..."
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

# --- SET UP NAT (exclude peering traffic if needed later) ---
echo "🔹 Setting up NAT on ${HOST_IF}"
sudo iptables -t nat -C POSTROUTING -s 10.0.1.0/24 -o ${HOST_IF} -j MASQUERADE 2>/dev/null \
  || sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o ${HOST_IF} -j MASQUERADE

# --- DISPLAY RESULT ---
echo "============================================================"
echo "✅ VPC ${VPC_NAME} successfully created!"
echo "Bridge IP: ${BRIDGE_IP}"
echo "Public Subnet IP: ${PUB_SUBNET_IP}"
echo "Private Subnet IP: ${PRIV_SUBNET_IP}"
echo "Host Interface: ${HOST_IF}"
echo "============================================================"

echo "🔹 Verify with:"
echo "  sudo ip netns exec ${PUBLIC_NS} ping -c 2 10.0.2.2"
echo "  sudo ip netns exec ${PUBLIC_NS} ping -c 2 8.8.8.8"
echo "============================================================"
