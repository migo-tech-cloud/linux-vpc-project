#!/bin/bash
# Usage: ./create_vpc_1.sh <VPC_NAME> <HOST_IFACE>
VPC_NAME=$1
HOST_IFACE=$2

BRIDGE="${VPC_NAME}-br0"
PUB_NS="${VPC_NAME}-public"
PRIV_NS="${VPC_NAME}-private"

# Bridge creation
sudo ip link add name $BRIDGE type bridge
sudo ip addr add 10.0.0.1/16 dev $BRIDGE
sudo ip link set $BRIDGE up

# Namespaces
sudo ip netns add $PUB_NS
sudo ip netns add $PRIV_NS

# Veths
sudo ip link add veth-pub type veth peer name veth-pub-br
sudo ip link add veth-priv type veth peer name veth-priv-br

# Attach veths to namespaces
sudo ip link set veth-pub netns $PUB_NS
sudo ip link set veth-priv netns $PRIV_NS

# Attach veth-br ends to bridge
sudo ip link set veth-pub-br master $BRIDGE
sudo ip link set veth-priv-br master $BRIDGE
sudo ip link set veth-pub-br up
sudo ip link set veth-priv-br up

# Assign IPs
sudo ip netns exec $PUB_NS ip addr add 10.0.1.2/16 dev veth-pub
sudo ip netns exec $PRIV_NS ip addr add 10.0.2.2/16 dev veth-priv

# Bring up interfaces inside namespaces
sudo ip netns exec $PUB_NS ip link set veth-pub up
sudo ip netns exec $PRIV_NS ip link set veth-priv up
sudo ip netns exec $PUB_NS ip link set lo up
sudo ip netns exec $PRIV_NS ip link set lo up

# Enable IP forwarding and NAT for Internet
sudo sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec $PUB_NS ip route add default via 10.0.0.1
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o $HOST_IFACE -j MASQUERADE

echo "✅ $VPC_NAME created successfully!"















