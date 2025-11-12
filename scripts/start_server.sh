#!/bin/bash
# Usage: ./start_server.sh <vpc_name> public|private
VPC_NAME=$1
SUBNET=$2

NS="${VPC_NAME}-${SUBNET}"

echo "🚀 Starting HTTP server in namespace $NS..."
sudo ip netns exec $NS python3 -m http.server 80 &
echo "✅ HTTP server started in $NS"

