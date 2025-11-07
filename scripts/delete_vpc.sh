#!/bin/bash
# Deletes VPC and cleans up resources

set -e
VPC_NAME=${1:-vpc1}

./vpcctl delete $VPC_NAME

echo "🧹 Cleaned up VPC resources for $VPC_NAME."
