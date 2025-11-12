
---

## **4️⃣ `add_subnet.sh`** (optional helper script)
```bash
#!/bin/bash
# Usage: ./add_subnet.sh <vpc_name> <subnet_name> <subnet_cidr>
VPC=$1
SUBNET=$2
CIDR=$3
BRIDGE="${VPC}-br0"
NS="${VPC}-${SUBNET}"
VETH="${SUBNET}-veth"
VETH_BR="${SUBNET}-veth-br"

echo "🔹 Adding subnet $SUBNET ($CIDR) to $VPC"

# Create namespace
sudo ip netns add $NS

# Create veth pair
sudo ip link add $VETH type veth peer name $VETH_BR
sudo ip link set $VETH netns $NS
sudo ip link set $VETH_BR master $BRIDGE
sudo ip link set $VETH_BR up

# Assign IP and bring up
sudo ip -n $NS addr add $CIDR dev $VETH
sudo ip -n $NS link set $VETH up

# Add default route via bridge
BR_IP=$(ip addr show $BRIDGE | grep -oP 'inet \K[\d.]+')
sudo ip -n $NS route add default via $BR_IP

echo "✅ Subnet $SUBNET added to $VPC"

