#!/bin/bash
# delete_vpcs.sh - Cleanup all VPCs, namespaces, bridges, and NAT rules

# Hardcoded VPC names
VPCS=("Migo-vpc-1" "Migo-vpc-2")

# Delete namespaces and bridges
for VPC in "${VPCS[@]}"; do
    echo "🧹 Deleting VPC: $VPC"

    # Delete public and private namespaces
    for NS_TYPE in "public" "private"; do
        NS="${VPC}-${NS_TYPE}"
        if ip netns list | grep -qw "$NS"; then
            sudo ip netns delete "$NS"
            echo "   ✅ Deleted namespace: $NS"
        else
            echo "   ⚠️ Namespace $NS does not exist"
        fi
    done

    # Delete bridge
    BR="${VPC}-br0"
    if ip link show type bridge | grep -qw "$BR"; then
        sudo ip link set "$BR" down
        sudo ip link delete "$BR" type bridge
        echo "   ✅ Deleted bridge: $BR"
    else
        echo "   ⚠️ Bridge $BR does not exist"
    fi
done

# Flush NAT table
sudo iptables -t nat -F
echo "✅ Flushed NAT table"

echo "✅ All VPCs cleaned up!"



