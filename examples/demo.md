# Demo: Linux-Based Virtual Private Cloud (VPC)

## Step 1: Create the VPC

./vpcctl create vpc1 10.0.0.0/16

## Step 2: Add Subnets

./vpcctl add-subnet vpc1 public 10.0.1.0/24 public
./vpcctl add-subnet vpc1 private 10.0.2.0/24 private

## Step 3: Test Connectivity

sudo ip netns exec vpc1-public ping -c 2 10.0.2.2

## Step 4: Deploy a Simple Web Server

sudo ip netns exec vpc1-public python3 -m http.server 80 &

## Step 5: Test Access

curl 10.0.1.2