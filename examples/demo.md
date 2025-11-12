# VPC Project Demo

This document demonstrates how to use the `vpcctl` CLI to create, peer, test, and clean up Migo-vpc-1 and Migo-vpc-2.

---

## Step-by-Step Demo

1. **Setup**

   chmod +x scripts/*.sh
   python3 vpcctl create
   
✅ Screenshot: Show Migo-vpc-1 and Migo-vpc-2 creation output.

Apply firewall rules

bash
Copy code
python3 vpcctl firewall
✅ Screenshot: Show firewall rules applied inside namespaces.

Start HTTP server

bash
Copy code
python3 vpcctl start-server
✅ Screenshot: Show server running in Migo-vpc-1-public.

Test connectivity

bash
Copy code
sudo ip netns exec Migo-vpc-1-public ping 10.0.2.2    # Intra-VPC
sudo ip netns exec Migo-vpc-1-public ping 8.8.8.8     # Internet
sudo ip netns exec Migo-vpc-1-private ping 8.8.8.8    # Should fail
✅ Screenshot: Show ping results.

Peering

bash
Copy code
python3 vpcctl peer
sudo ip netns exec Migo-vpc-1-public ping 10.1.1.2
✅ Screenshot: Show successful cross-VPC communication.

Stop servers and cleanup

bash
Copy code
python3 vpcctl stop-server
python3 vpcctl unpeer
python3 vpcctl delete