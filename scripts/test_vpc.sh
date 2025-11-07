#!/bin/bash
# Runs connectivity tests between subnets

echo "🚀 Testing connectivity between subnets..."
sudo ip netns exec vpc1-public ping -c 2 10.0.2.2 || echo "Ping failed (expected if private subnet is isolated)"

echo "🌍 Testing internet access from public subnet..."
sudo ip netns exec vpc1-public curl -I https://example.com || echo "No internet access"

echo "🔒 Testing blocked access from private subnet..."
sudo ip netns exec vpc1-private curl -I https://example.com || echo "Private subnet correctly isolated"
