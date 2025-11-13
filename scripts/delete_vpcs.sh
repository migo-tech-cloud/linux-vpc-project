#!/bin/bash
# scripts/delete_vpcs.sh
# Final version for deleting all VPCs and cleaning up resources

set -euo pipefail

VPCS=("Migo-vpc-1" "Migo-vpc-2")

echo "🧹 Deleting all VPCs..."

for VPC in "${VPCS[@]}"; do
    echo "🔹 Deleting VPC: $VPC"

    # Delete public namespace if it exists
    if ip netns list | grep -qw "${VPC}-public"; then
        sudo ip netns delete "${VPC}-public"
        echo "   ✅ Deleted namespace: ${VPC}-public"
    else
        echo "   ⚠️ Namespace ${VPC}-public does not exist, skipping."
    fi

    # Delete private namespace if it exists
    if ip netns list | grep -qw "${VPC}-private"; then
        sudo ip netns delete "${VPC}-private"
        echo "   ✅ Deleted namespace: ${VPC}-private"
    else
        echo "   ⚠️ Namespace ${VPC}-private does not exist, skipping."
    fi

    # Delete bridge if it exists
    if ip link show type bridge | grep -qw "${VPC}-br0"; then
        sudo ip link set "${VPC}-br0" down
        sudo ip link delete "${VPC}-br0" type bridge
        echo "   ✅ Deleted bridge: ${VPC}-br0"
    else
        echo "   ⚠️ Bridge ${VPC}-br0 does not exist, skipping."
    fi
done

# Flush NAT table to remove MASQUERADE rules
sudo iptables -t nat -F
echo "🔹 Flushed NAT table."

echo "✅ Cleanup completed. All VPCs removed."




