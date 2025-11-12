#!/bin/bash
# ============================================================
# delete_vpcs.sh — Remove all VPCs, bridges, veths, and namespaces
# ============================================================

echo "🧹 Cleaning up all VPCs..."

for VPC in Migo-vpc-1 Migo-vpc-2; do
    echo "🔹 Deleting VPC: $VPC"

    # Delete namespaces
    ip netns del ${VPC}-public 2>/dev/null
    ip netns del ${VPC}-private 2>/dev/null

    # Delete bridge
    ip link del ${VPC}-br0 2>/dev/null

    # Delete veth pairs (if they still exist)
    ip link del veth-pub 2>/dev/null
    ip link del veth-priv 2>/dev/null
    ip link del veth2-pub 2>/dev/null
    ip link del veth2-priv 2>/dev/null
done

# Flush NAT rules for host interface
HOST_IFACE="enX0"
iptables -t nat -D POSTROUTING -o ${HOST_IFACE} -j MASQUERADE 2>/dev/null

echo "✅ Cleanup completed. All VPCs removed."

