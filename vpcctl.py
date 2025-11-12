#!/usr/bin/env python3
import os
import sys
import subprocess
import logging

# ------------------- Logging -------------------
logging.basicConfig(
    format='%(asctime)s | %(levelname)s | %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S'
)

def run_cmd(cmd):
    logging.info(f"🔹 Running command: {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        logging.error(f"❌ Command failed with exit code {result.returncode}")
    return result.returncode

# ------------------- VPC Definitions -------------------
VPCS = [
    {"name": "Migo-vpc-1", "bridge": "Migo-vpc-1-br0", "script": "scripts/create_vpc1.sh"},
    {"name": "Migo-vpc-2", "bridge": "Migo-vpc-2-br0", "script": "scripts/create_vpc2.sh"},
]

HOST_INTERFACE = "enX0"  # Your actual host interface

# ------------------- Commands -------------------
def create_vpcs():
    logging.info("🚀 Starting VPC creation process...")
    for vpc in VPCS:
        logging.info(f"Creating {vpc['name']} using {vpc['script']}")
        run_cmd(f"bash {vpc['script']} {vpc['name']} {HOST_INTERFACE}")
    logging.info("✅ All VPCs created successfully!")

def delete_vpcs():
    logging.info("🧹 Cleaning up all VPCs...")
    for vpc in VPCS:
        pub_ns = f"{vpc['name']}-public"
        priv_ns = f"{vpc['name']}-private"
        bridge = vpc["bridge"]

        logging.info(f"🔹 Deleting VPC: {vpc['name']}")

        # Delete namespaces if they exist
        if os.system(f"ip netns list | grep -qw {pub_ns}") == 0:
            run_cmd(f"sudo ip netns delete {pub_ns}")
        if os.system(f"ip netns list | grep -qw {priv_ns}") == 0:
            run_cmd(f"sudo ip netns delete {priv_ns}")

        # Delete bridge if it exists
        if os.system(f"ip link show {bridge} >/dev/null 2>&1") == 0:
            run_cmd(f"sudo ip link set {bridge} down")
            run_cmd(f"sudo ip link delete {bridge} type bridge")

    # Flush NAT rules
    run_cmd("sudo iptables -t nat -F")
    logging.info("✅ Cleanup completed. All VPCs removed.")

def start_server(namespace="Migo-vpc-1-public", port=80):
    logging.info(f"🚀 Starting HTTP server in {namespace} on port {port}")
    run_cmd(f"sudo ip netns exec {namespace} nohup python3 -m http.server {port} >/dev/null 2>&1 &")
    logging.info(f"✅ HTTP server started in {namespace}:{port}")

def stop_server():
    logging.info("🛑 Stopping all HTTP servers...")
    run_cmd("sudo pkill -f 'python3 -m http.server'")
    logging.info("✅ All HTTP servers stopped.")

def show_help():
    help_text = """
Usage: python3 vpcctl.py <command> [options]

Commands:
  create             Create all hardcoded VPCs
  delete             Delete all VPCs and cleanup
  start-server       Start HTTP server in a namespace (default Migo-vpc-1-public, port 80)
  stop-server        Stop all HTTP servers
  help               Show this help
"""
    print(help_text)

# ------------------- CLI Handling -------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_help()
        sys.exit(1)

    cmd = sys.argv[1].lower()
    if cmd == "create":
        create_vpcs()
    elif cmd == "delete":
        delete_vpcs()
    elif cmd == "start-server":
        ns = sys.argv[2] if len(sys.argv) > 2 else "Migo-vpc-1-public"
        port = int(sys.argv[3]) if len(sys.argv) > 3 else 80
        start_server(namespace=ns, port=port)
    elif cmd == "stop-server":
        stop_server()
    elif cmd == "help":
        show_help()
    else:
        logging.error(f"❌ Unknown command: {cmd}")
        show_help()












