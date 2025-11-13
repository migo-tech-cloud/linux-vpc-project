#!/bin/bash
# Delete all VPC namespaces and bridges

for VPC in Migo-vpc-1 Migo-vpc-2; do
    PUB_NS="${VPC}-public"
    PRIV_NS="${VPC}-private"
    BRIDGE="${VPC}-br0"

    echo "🧹 Deleting $VPC..."

    sudo ip netns delete $PUB_NS 2>/dev/null || true
    sudo ip netns delete $PRIV_NS 2>/dev/null || true
    sudo ip link set $BRIDGE down 2>/dev/null || true
    sudo ip link delete $BRIDGE type bridge 2>/dev/null || true
done

# Flush NAT rules
sudo iptables -t nat -F

echo "✅ All VPCs removed."







