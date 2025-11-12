## **2️⃣ `README.md`**

## 🧠 Author

Owajimimin John — DevOps Intern

## This project demonstrates deep Linux networking, isolation, and automation skills.

---

```markdown
# Linux VPC Project

**Overview:**
This project simulates a Virtual Private Cloud (VPC) on a single Linux host using network namespaces, veth pairs, bridges, routing, and iptables. You can create multiple VPCs, public/private subnets, NAT gateways, and VPC peering.

**Features:**
- Create multiple VPCs with unique CIDRs
- Public and private subnets
- NAT gateway for public subnets
- VPC isolation and peering
- Firewall rules (Security Groups)
- Easy automation via `vpcctl.py`

**Usage:**

# Create VPCs
python3 vpcctl.py create

# Peer VPCs
python3 vpcctl.py peer

# Start demo HTTP server in Migo-vpc-1 public subnet
python3 vpcctl.py start-server

# Stop demo HTTP servers
python3 vpcctl.py stop-server

# Clean up all VPC resources
python3 vpcctl.py cleanup

**Project Structure:**

vpc-project/
├── vpcctl.py
├── config/policies.json
├── scripts/
├── examples/demo.md
├── README.md
└── runbook.md

**Notes:**

- Hardcoded VPC names: Migo-vpc-1 and Migo-vpc-2

- Host interface in EC2: enX0

- All actions are logged in the terminal



