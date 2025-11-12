#!/bin/bash
# peer_vpcs.sh
# Usage: bash peer_vpcs.sh

# Connect Migo-vpc-1 <-> Migo-vpc-2

# Create veth pair between bridges
ip link add vpc1-peer type veth peer name vpc2-peer
ip link set vpc1-peer master vpc1-br0
ip link set vpc2-peer master vpc2-br0
ip link set vpc1-peer up
ip link set vpc2-peer up

# Add static routes for subnets
ip route add 10.1.0.0/16 dev vpc1-br0
ip route add 10.0.0.0/16 dev vpc2-br0

# Exclude peering traffic from NAT
iptables -t nat -I POSTROUTING 1 -s 10.0.0.0/16 -d 10.1.0.0/16 -j RETURN
iptables -t nat -I POSTROUTING 1 -s 10.1.0.0/16 -d 10.0.0.0/16 -j RETURN

echo "✅ VPC peering established between Migo-vpc-1 and Migo-vpc-2"


