#!/bin/bash
# ============================================================
# cleanup.sh — Safely remove all VPC1 resources
# Author: Owajimimin John
# ============================================================

set -e
set -u

# --- CONFIGURATION ---
VPC_NAME="vpc1"
BRIDGE_NAME="${VPC_NAME}-br0"
PUBLIC_NS="${VPC_NAME}-public"
PRIVATE_NS="${VPC_NAME}-private"
HOST_IF="enX0"   

echo "============================================================"
echo "🧹 Cleaning up ${VPC_NAME} environment..."
echo "============================================================"

# --- REMOVE NAT RULES ---
echo "🔹 Removing NAT rules (if any)..."
sudo iptables -t nat -D POSTROUTING -s 10.0.1.0/24 -o ${HOST_IF} -j MASQUERADE 2>/dev/null || true
sudo iptables -t nat -D POSTROUTING -s 10.0.2.0/24 -o ${HOST_IF} -j MASQUERADE 2>/dev/null || true

# --- DELETE DEFAULT ROUTES INSIDE NAMESPACES ---
echo "🔹 Deleting routes..."
sudo ip -n ${PUBLIC_NS} route del default 2>/dev/null || true
sudo ip -n ${PRIVATE_NS} route del default 2>/dev/null || true

# --- DELETE NAMESPACES (also deletes their interfaces) ---
echo "🔹 Deleting namespaces..."
sudo ip netns del ${PUBLIC_NS} 2>/dev/null || true
sudo ip netns del ${PRIVATE_NS} 2>/dev/null || true

# --- DELETE VETH PAIRS AND BRIDGE ---
echo "🔹 Removing bridge and veth interfaces..."
for iface in veth-pub-br veth-priv-br ${BRIDGE_NAME}; do
  sudo ip link del $iface 2>/dev/null || true
done

# --- RESET SYSCTL ---
echo "🔹 Disabling IP forwarding..."
echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null

echo "============================================================"
echo "✅ Cleanup complete for ${VPC_NAME}!"
echo "============================================================"
