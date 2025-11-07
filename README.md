> **Purpose:** Project overview and usage guide.


# 🏗️ Build Your Own Virtual Private Cloud (VPC) on Linux

This project recreates how cloud platforms like AWS implement Virtual Private Clouds — using only native Linux networking tools.

---

## 🚀 Features
- Create and delete virtual VPCs.
- Add public/private subnets using Linux network namespaces.
- Enable routing between subnets.
- Simulate NAT gateway for outbound access.
- Enforce security group–like firewall rules.
- Support optional VPC peering.
- Full lifecycle automation via `vpcctl` CLI.

---

## 🧰 Tools Used
- `ip`, `ip netns`, `bridge`, `veth`, `iptables`
- `bash` scripting for automation
- `curl` and `ping` for testing
- `python3 -m http.server` for app simulation

---

## 🧩 Project Structure
Refer to the folder layout in this repo.

---

## 💻 Quick Start

chmod +x vpcctl
./scripts/create_vpc.sh
./scripts/test_vpc.sh
./scripts/delete_vpc.sh

---

## 🎯 Expected Behavior

# Test------------------------------------->>Expected Result

Same VPC communication------------------->>✅ Works

Internet access from public subnet------->>✅ Works

Internet access from private subnet------>>❌ Blocked

Inter-VPC communication------------------>>❌ Blocked

After peering---------------------------->>✅ Controlled communication

---

## 🧹 Cleanup

Run:
./scripts/delete_vpc.sh vpc1

---

## 🧠 Author

Owajimimin John — DevOps Intern

---

## This project demonstrates deep Linux networking, isolation, and automation skills.