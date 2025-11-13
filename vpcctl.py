#!/usr/bin/env python3
import subprocess
import sys
import logging

# -------------------
# Logging configuration
# -------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

# -------------------
# Constants
# -------------------
HOST_IFACE = "enX0"
VPCS = ["Migo-vpc-1", "Migo-vpc-2"]
CREATE_SCRIPTS = ["scripts/create_vpc_1.sh", "scripts/create_vpc_2.sh"]

# -------------------
# Helper function
# -------------------
def run_cmd(cmd):
    logging.info(f"🔹 Running command: {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        logging.error(f"❌ Command failed with exit code {result.returncode}")
    return result.returncode

# -------------------
# Command implementations
# -------------------
def create_vpcs():
    logging.info("🚀 Starting VPC creation process...")
    for vpc, script in zip(VPCS, CREATE_SCRIPTS):
        logging.info(f"Creating {vpc} using {script}")
        run_cmd(f"bash {script} {vpc} {HOST_IFACE}")
    logging.info("✅ All VPCs created successfully!")

def delete_vpcs():
    logging.info("🧹 Cleaning up all VPCs...")
    for vpc in VPCS:
        pub_ns = f"{vpc}-public"
        priv_ns = f"{vpc}-private"
        bridge = f"{vpc}-br0"
        logging.info(f"🔹 Deleting VPC: {vpc}")
        run_cmd(f"sudo ip netns delete {pub_ns} 2>/dev/null || true")
        run_cmd(f"sudo ip netns delete {priv_ns} 2>/dev/null || true")
        run_cmd(f"sudo ip link set {bridge} down 2>/dev/null || true")
        run_cmd(f"sudo ip link delete {bridge} type bridge 2>/dev/null || true")
    run_cmd("sudo iptables -t nat -F")
    logging.info("✅ Cleanup completed. All VPCs removed.")

def start_server(namespace="Migo-vpc-1-public", port=80):
    logging.info(f"🚀 Starting HTTP server in namespace {namespace} on port {port}...")
    run_cmd(f"sudo ip netns exec {namespace} python3 -m http.server {port} &")
    logging.info("✅ Server started.")

def stop_server():
    logging.info("🛑 Stopping all HTTP servers...")
    run_cmd("sudo pkill -f 'python3 -m http.server'")
    logging.info("✅ All servers stopped.")

def print_help():
    print("""
Usage: python3 vpcctl.py <command> [options]

Commands:
  create             Create all hardcoded VPCs
  delete             Delete all VPCs and cleanup
  start-server       Start HTTP server in a namespace (default Migo-vpc-1-public, port 80)
  stop-server        Stop all HTTP servers
  help               Show this help
""")

# -------------------
# Main entry point
# -------------------
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print_help()
        sys.exit(1)

    cmd = sys.argv[1].lower()

    if cmd == "create":
        create_vpcs()
    elif cmd == "delete":
        delete_vpcs()
    elif cmd == "start-server":
        ns = sys.argv[2] if len(sys.argv) > 2 else "Migo-vpc-1-public"
        port = int(sys.argv[3]) if len(sys.argv) > 3 else 80
        start_server(ns, port)
    elif cmd == "stop-server":
        stop_server()
    elif cmd == "help":
        print_help()
    else:
        logging.error(f"❌ Unknown command: {cmd}")
        print_help()
















