#!/bin/bash
# ============================================================
# delete_vpcs.sh — Clean up all VPC namespaces, bridges, and veth pairs
# Compatible with Migo-vpc-1 and Migo-vpc-2
# ============================================================

echo "🧹 Starting full cleanup..."

# List of known namespaces
namespaces=("Migo-vpc-1-public" "Migo-vpc-1-private" "Migo-vpc-2-public" "Migo-vpc-2-private")

# Delete namespaces safely
for ns in "${namespaces[@]}"; do
  if ip netns list | grep -qw "$ns"; then
    echo "🔸 Deleting namespace: $ns"
    sudo ip netns delete "$ns"
  fi
done

# Delete bridges
bridges=("Migo-vpc-1-br0" "Migo-vpc-2-br0")
for br in "${bridges[@]}"; do
  if ip link show "$br" &>/dev/null; then
    echo "🔹 Deleting bridge: $br"
    sudo ip link set "$br" down
    sudo ip link delete "$br" type bridge
  fi
done

# Delete any orphaned veth pairs
echo "🔹 Cleaning up orphaned veth interfaces..."
for link in $(ip link show | grep -oE 'veth-[^:@]+' | sort -u); do
  echo "   🧩 Removing $link"
  sudo ip link delete "$link" 2>/dev/null
done

# Flush IP tables NAT rules related to enX0
echo "🔹 Resetting iptables NAT rules..."
sudo iptables -t nat -F
sudo iptables -F

echo "✅ Cleanup complete!"
