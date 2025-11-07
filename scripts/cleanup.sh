#!/bin/bash
# ------------------------------------------------------------------------------
# cleanup.sh — Safely remove all virtual VPC components
# Description:
#   This script cleans up any virtual networks, bridges, veth pairs,
#   and network namespaces created during your VPC project experiments.
# ------------------------------------------------------------------------------

set -e

echo "=========================================="
echo "🧹  Starting VPC Environment Cleanup"
echo "=========================================="

# Delete all network namespaces
echo "[+] Deleting all network namespaces..."
for ns in $(ip netns list | awk '{print $1}'); do
  echo "    -> Removing namespace: $ns"
  sudo ip netns delete "$ns" || echo "      (Namespace $ns not found)"
done

# Delete all Linux bridges
echo "[+] Deleting all Linux bridges..."
for br in $(ip link show type bridge | awk -F: '{print $2}' | awk '{print $1}'); do
  echo "    -> Removing bridge: $br"
  sudo ip link delete "$br" type bridge 2>/dev/null || echo "      (Bridge $br not found)"
done

# Delete all veth pairs
echo "[+] Deleting all veth pairs..."
for veth in $(ip link show | grep veth | awk -F: '{print $2}' | awk '{print $1}'); do
  echo "    -> Removing veth: $veth"
  sudo ip link delete "$veth" 2>/dev/null || echo "      (veth $veth not found)"
done

echo "=========================================="
echo "✅  Cleanup complete — environment reset."
echo "=========================================="
