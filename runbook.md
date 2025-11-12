## **3️⃣ `runbook.md`**
```markdown
# Linux VPC Project Runbook

## Purpose:
Guide for setup, testing, troubleshooting, and cleanup of Migo VPCs.

---

## 1. Setup
1. SSH into your EC2 instance (via MobaXterm)
2. Clone the repository:

git clone https://github.com/<your-username>/linux-vpc-project.git
cd linux-vpc-project
3. Ensure scripts are executable:

chmod +x scripts/*.sh
## 2. Running the Demo
1. Create VPCs:

python3 vpcctl.py create
2. Peer VPCs:

python3 vpcctl.py peer
3. Start demo HTTP server:

python3 vpcctl.py start-server

4. Verify connectivity between subnets and NAT.

## 3. Troubleshooting
- Error: Nexthop has invalid gateway → Ensure veths and bridge IPs match subnet CIDR.

- Ping fails between namespaces → Check link states: ip link & ip netns exec <ns> ip addr.

- HTTP server not reachable → Ensure IP assigned inside namespace and server running.

## 4. Cleanup

python3 vpcctl.py cleanup
Confirms all namespaces, bridges, veths, and NAT rules are removed.

## 5. Notes
- Hardcoded VPC names: Migo-vpc-1 and Migo-vpc-2

- Host interface: enX0

- Screenshots recommended after creation, peering, server start, and cleanup.


