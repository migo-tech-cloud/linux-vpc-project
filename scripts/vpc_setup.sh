#!/bin/bash

# STEP 1 — Create Two Bridges (VPCs)
#In your terminal (MobaXterm or Ubuntu CLI):
sudo ip link add vpc1-br0 type bridge
sudo ip link add vpc2-br0 type bridge

sudo ip addr add 10.0.0.1/16 dev vpc1-br0
sudo ip addr add 10.1.0.1/16 dev vpc2-br0

sudo ip link set vpc1-br0 up
sudo ip link set vpc2-br0 up


✅ Result
You’ve created two private networks:

vpc1 → 10.0.0.0/16

vpc2 → 10.1.0.0/16

Each bridge acts like a “virtual switch.”

🧍 STEP 2 — Create Two Virtual Machines (veth Pairs)

We’ll simulate an instance inside each VPC.

sudo ip link add vpc1-peer type veth peer name vpc1-host
sudo ip link add vpc2-peer type veth peer name vpc2-host

# Attach "peer" ends to each VPC bridge
sudo ip link set vpc1-peer master vpc1-br0
sudo ip link set vpc2-peer master vpc2-br0

sudo ip link set vpc1-peer up
sudo ip link set vpc2-peer up


✅ vpc1-host and vpc2-host will act like VMs inside each VPC.

🧱 STEP 3 — Create Network Namespaces (Simulate Instances)

This isolates each “VM” in its own namespace.

sudo ip netns add ns1
sudo ip netns add ns2

sudo ip link set vpc1-host netns ns1
sudo ip link set vpc2-host netns ns2

sudo ip -n ns1 addr add 10.0.0.10/16 dev vpc1-host
sudo ip -n ns2 addr add 10.1.0.10/16 dev vpc2-host

sudo ip -n ns1 link set vpc1-host up
sudo ip -n ns2 link set vpc2-host up


Add default routes:

sudo ip -n ns1 route add default via 10.0.0.1
sudo ip -n ns2 route add default via 10.1.0.1


✅ Now, ns1 → 10.0.0.10 (inside vpc1)
and ns2 → 10.1.0.10 (inside vpc2)

🌐 STEP 4 — Enable Internet Access (MASQUERADE)

On your host (not inside a namespace):

sudo sysctl -w net.ipv4.ip_forward=1


Then add NAT for both VPCs:

sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.1.0.0/16 -o eth0 -j MASQUERADE


✅ Each VPC now has internet access through your host machine’s interface (eth0).

🪄 STEP 5 — Create VPC Peering (Direct Connection)

We’ll now create a veth pair connecting both VPC bridges.

sudo ip link add vpc1-peerlink type veth peer name vpc2-peerlink

sudo ip link set vpc1-peerlink master vpc1-br0
sudo ip link set vpc2-peerlink master vpc2-br0

sudo ip link set vpc1-peerlink up
sudo ip link set vpc2-peerlink up


Now each VPC bridge can send traffic directly to the other.

🚫 STEP 6 — Exclude Peering Traffic from MASQUERADE

This is the crucial fix you mentioned:

sudo iptables -t nat -I POSTROUTING 1 -s 10.0.0.0/16 -d 10.1.0.0/16 -j RETURN
sudo iptables -t nat -I POSTROUTING 1 -s 10.1.0.0/16 -d 10.0.0.0/16 -j RETURN


✅ Now, traffic between vpc1 and vpc2 is not NATed — only internet-bound traffic is.

🧪 STEP 7 — Test Everything

In MobaXterm or terminal:

sudo ip netns exec ns1 ping -c 3 10.0.0.1       # gateway of vpc1
sudo ip netns exec ns2 ping -c 3 10.1.0.1       # gateway of vpc2

sudo ip netns exec ns1 ping -c 3 10.1.0.10      # test cross-vpc peering
sudo ip netns exec ns1 ping -c 3 8.8.8.8        # test internet


✅ Expected:

All pings should succeed.

vpc1 ↔ vpc2 traffic routes directly (no NAT).

Both VPCs have internet access.

💡 STEP 8 — Save Your Setup

In VS Code:

Create a file named vpc_setup.sh

Paste all commands from above (steps 1–7).

Add #!/bin/bash at the top.

Make it executable:

chmod +x vpc_setup.sh


Now you can recreate the entire lab anytime with:

sudo ./vpc_setup.sh