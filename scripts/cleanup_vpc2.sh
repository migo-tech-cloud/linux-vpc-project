#!/bin/bash
set -e

echo "============================================================"
echo "🧹 Cleaning up VPC2 and its peering..."
echo "============================================================"

# Interfaces and namespaces
BRIDGE="vpc2-br0"
PUB_NS="vpc2-public"
PRIV_NS="vpc2-private"

# Remove NAT & peering rules
sudo iptables -t nat -D POSTROUTING -s 10.0.0.0/16 -d 10.1.0.0/16 -j ACCEPT 2>/dev/null || true
sudo iptables -t nat -D POSTROUTING -s 10.1.0.0/16 -d 10.0.0.0/16 -j ACCEPT 2>/dev/null || true
sudo iptables -t nat -D POSTROUTING -s 10.1.0.0/16 -o enX0 -j MASQUERADE 2>/dev/null || true

# Delete veth pairs if they exist
for v in veth2-pub veth2-pub-br veth2-priv veth2-priv-br vpc1-peer vpc2-peer; do
  sudo ip link delete $v 2>/dev/null || true
done

# Delete namespaces
for ns in $PUB_NS $PRIV_NS; do
  sudo ip netns delete $ns 2>/dev/null || true
done

# Delete bridge
sudo ip link set $BRIDGE down 2>/dev/null || true
sudo ip link delete $BRIDGE type bridge 2>/dev/null || true

echo "============================================================"
echo "✅ VPC2 + Peering removed successfully!"
echo "============================================================"
