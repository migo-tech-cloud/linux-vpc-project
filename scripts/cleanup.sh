#!/bin/bash
# Remove namespaces
ip netns delete Migo-vpc-1-public 2>/dev/null
ip netns delete Migo-vpc-1-private 2>/dev/null
ip netns delete Migo-vpc-2-public 2>/dev/null
ip netns delete Migo-vpc-2-private 2>/dev/null

# Remove bridges
ip link delete vpc1-br0 type bridge 2>/dev/null
ip link delete vpc2-br0 type bridge 2>/dev/null

# Remove peering veth
ip link delete vpc1-peer 2>/dev/null
ip link delete vpc2-peer 2>/dev/null

# Flush NAT rules
iptables -t nat -F

echo "✅ Cleanup complete"


