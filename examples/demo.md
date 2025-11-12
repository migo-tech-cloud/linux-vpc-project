# VPC Project Demo

This document demonstrates how to use the `vpcctl` CLI to create, peer, test, and clean up Migo-vpc-1 and Migo-vpc-2.

---

## 1. Create VPCs

python3 vpcctl.py create
Expected Output:

- Creation of Migo-vpc-1 and Migo-vpc-2 bridges

- Namespaces for public and private subnets

- NAT enabled for public subnets

*Screenshot: Show ip link and ip netns list to confirm bridges and namespaces.*

## 2. Peer VPCs

python3 vpcctl.py peer
Expected Output:

- Peering link created between Migo-vpc-1 and Migo-vpc-2

- NAT rules exclude peering traffic

*Screenshot: Show successful ping from Migo-vpc-1 public subnet to Migo-vpc-2 public subnet.*

## 3. Start Demo HTTP Server

python3 vpcctl.py start-server
Test Connectivity:

sudo ip netns exec Migo-vpc-1-public curl 10.0.1.2
sudo ip netns exec Migo-vpc-2-public curl 10.1.1.2

*Screenshot: Show HTTP server responses for both VPCs.*

## 4. Stop Demo HTTP Server

python3 vpcctl.py stop-server

*Screenshot: Show ps aux | grep python3 has no running servers.*

## 5. Cleanup All Resources

python3 vpcctl.py cleanup
Expected Output:

- All bridges, namespaces, and veths removed

- NAT rules flushed

*Screenshot: Show ip netns list is empty and ip link only has host interfaces.*