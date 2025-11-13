#!/bin/bash
# Usage: ./peer_vpcs.sh
# Sets up VPC peering between Migo-vpc-1 and Migo-vpc-2
# Excludes peering traffic from NAT (MASQUERADE)

set -e

VPC1_BR="Migo-vpc-1-br0"
VPC2_BR="Migo-vpc-2-br0"

# Create a veth pair connecting the two bridges
sudo ip link add vpc1-to-vpc2 type veth peer name vpc2-to-vpc1

# Attach ends to each bridge
sudo ip link set vpc1-to-vpc2 master $VPC1_BR
sudo ip link set vpc2-to-vpc1 master $VPC2_BR

# Bring interfaces up
sudo ip link set vpc1-to-vpc2 up
sudo ip link set vpc2-to-vpc1 up

# Assign IPs for peering
sudo ip addr add 10.255.0.1/24 dev vpc1-to-vpc2
sudo ip addr add 10.255.0.2/24 dev vpc2-to-vpc1

# Add routes in namespaces to reach the other VPC
for NS in Migo-vpc-1-public Migo-vpc-1-private; do
    sudo ip netns exec $NS ip route add 10.1.0.0/16 via 10.255.0.2
done

for NS in Migo-vpc-2-public Migo-vpc-2-private; do
    sudo ip netns exec $NS ip route add 10.0.0.0/16 via 10.255.0.1
done

# Exclude peering traffic from NAT
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -d 10.1.0.0/16 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -d 10.0.0.0/16 -j ACCEPT

echo "✅ VPC peering established between Migo-vpc-1 and Migo-vpc-2"





