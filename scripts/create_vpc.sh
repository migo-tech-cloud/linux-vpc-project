#!/bin/bash
# Creates a sample VPC environment for testing

set -e
./vpcctl create vpc1 10.0.0.0/16
./vpcctl add-subnet vpc1 public 10.0.1.0/24 public
./vpcctl add-subnet vpc1 private 10.0.2.0/24 private

echo "✅ VPC created with public and private subnets."
