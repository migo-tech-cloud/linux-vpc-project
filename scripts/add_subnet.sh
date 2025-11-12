#!/bin/bash
# Usage: bash add_subnet.sh <VPC_NAME> <SUBNET_NAME> <CIDR>
# Example: bash add_subnet.sh Migo-vpc-1 public 10.0.3.2/16

VPC_NAME=$1
SUBNET=$2
CIDR=$3

NS_NAME="${VPC_NAME}-${SUBNET}"
VETH_NS="veth-${SUBNET}"
VETH_BR="veth-${SUBNET}-br"

echo "🔹 Adding subnet: $NS_NAME"

# Create namespace
ip netns add $NS_NAME

# Create veth pair and connect to bridge
ip link add $VETH_NS type veth peer name $VETH_BR
ip link set $VETH_NS netns $NS_NAME
ip link set $VETH_BR master ${VPC_NAME}-br0
ip link set $VETH_BR up

# Assign IP and bring up namespace interface
ip -n $NS_NAME addr add $CIDR dev $VETH_NS
ip -n $NS_NAME link set $VETH_NS up

# Add default route via bridge
ip -n $NS_NAME route add default via $(echo $CIDR | cut -d"." -f1-2).0.1 2>/dev/null

echo "✅ Subnet $NS_NAME added successfully!"


