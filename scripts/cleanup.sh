#!/bin/bash
echo "🧹 Cleaning up all VPCs..."

# Delete namespaces
for ns in Migo-vpc-1-public Migo-vpc-1-private Migo-vpc-2-public Migo-vpc-2-private; do
    sudo ip netns delete $ns 2>/dev/null
done

# Delete bridges
for br in Migo-vpc-1-br0 Migo-vpc-2-br0; do
    sudo ip link delete $br type bridge 2>/dev/null
done

# Delete veth pairs (if exist)
for v in veth-pub veth-pub-br veth-priv veth-priv-br Migo-vpc-1-to-Migo-vpc-2 Migo-vpc-2-to-Migo-vpc-1; do
    sudo ip link delete $v 2>/dev/null
done

# Flush NAT rules
sudo iptables -t nat -F

echo "✅ Cleanup complete!"

