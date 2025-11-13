#!/bin/bash
# Usage: ./delete_vpcs.sh
# Fully cleans up all VPCs, bridges, namespaces, and NAT rules

set -e

VPCS=("Migo-vpc-1" "Migo-vpc-2")

echo "🧹 Cleaning up all VPCs..."

for VPC in "${VPCS[@]}"; do
    PUB_NS="${VPC}-public"
    PRIV_NS="${VPC}-private"
    BRIDGE="${VPC}-br0"

    echo "🔹 Deleting VPC: $VPC"

    # Delete namespaces if they exist
    sudo ip netns delete $PUB_NS 2>/dev/null || true
    sudo ip netns delete $PRIV_NS 2>/dev/null || true

    # Bring bridge down and delete it if it exists
    sudo ip link set $BRIDGE down 2>/dev/null || true
    sudo ip link delete $BRIDGE type bridge 2>/dev/null || true
done

# Flush NAT rules
sudo iptables -t nat -F

echo "✅ Cleanup completed. All VPCs removed."





