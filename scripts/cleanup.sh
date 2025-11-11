#!/bin/bash
# ------------------------------------------------------------------------------
# cleanup.sh — Safely remove all virtual VPC components
# Author: Your Name
# Description:
#   This script cleans up any virtual networks, bridges, veth pairs,
#   and network namespaces created during your VPC project experiments.
# ------------------------------------------------------------------------------

set -e

echo "=========================================="
echo "🧹  Starting VPC Environment Cleanup"
echo "=========================================="

# Delete namespaces
for ns in $(ip netns list | awk '{print $1}'); do
  echo "Deleting namespace: $ns"
  ip netns delete $ns
done

# Delete bridges
for br in $(ip link show type bridge | awk -F: '{print $2}' | awk '{print $1}'); do
  echo "Deleting bridge: $br"
  ip link set $br down
  ip link delete $br type bridge
done

# Delete veth pairs
for veth in $(ip link show | grep veth | awk -F: '{print $2}' | awk '{print $1}'); do
  echo "Deleting veth: $veth"
  ip link delete $veth 2>/dev/null
done

# Flush iptables
iptables -t nat -F
iptables -F
iptables -X

echo "[✓] Cleanup complete. System reset to default networking state."
