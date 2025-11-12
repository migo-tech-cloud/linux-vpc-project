#!/bin/bash
# Usage: ./peer_vpcs.sh Migo-vpc-1 Migo-vpc-2
VPC1=$1
VPC2=$2

# Veth pair for peering bridges
sudo ip link add ${VPC1}-to-${VPC2} type veth peer name ${VPC2}-to-${VPC1}

# Attach ends to respective bridges
sudo ip link set ${VPC1}-to-${VPC2} master ${VPC1}-br0
sudo ip link set ${VPC2}-to-${VPC1} master ${VPC2}-br0

# Bring up
sudo ip link set ${VPC1}-to-${VPC2} up
sudo ip link set ${VPC2}-to-${VPC1} up

# Add static routes to each VPC for the other
sudo ip route add 10.1.0.0/16 dev ${VPC1}-to-${VPC2} 2>/dev/null
sudo ip route add 10.0.0.0/16 dev ${VPC2}-to-${VPC1} 2>/dev/null

# Exclude peering traffic from NAT
sudo iptables -t nat -I POSTROUTING 1 -s 10.0.0.0/16 -d 10.1.0.0/16 -j RETURN
sudo iptables -t nat -I POSTROUTING 1 -s 10.1.0.0/16 -d 10.0.0.0/16 -j RETURN

echo "🤝 Peering established between $VPC1 and $VPC2"

