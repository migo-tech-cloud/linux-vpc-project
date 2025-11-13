#!/usr/bin/env python3
import subprocess
import sys
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S"
)
logger = logging.getLogger()

# Hardcoded VPCs
VPCS = [
    {"name": "Migo-vpc-1", "script": "scripts/create_vpc_1.sh"},
    {"name": "Migo-vpc-2", "script": "scripts/create_vpc_2.sh"}
]

# Default host interface
HOST_IFACE = "enX0"

def run_command(cmd):
    logger.info(f"🔹 Running command: {cmd}")
    try:
        subprocess.run(cmd, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"❌ Command failed with exit code {e.returncode}")

def create_vpcs():
    logger.info("🚀 Starting VPC creation process...")
    for vpc in VPCS:
        logger.info(f"Creating {vpc['name']} using {vpc['script']}")
        run_command(f"bash {vpc['script']} {vpc['name']} {HOST_IFACE}")
    logger.info("✅ All VPCs created successfully!")

def delete_vpcs():
    logger.info("🧹 Cleaning up all VPCs...")
    for vpc in VPCS:
        logger.info(f"🔹 Deleting VPC: {vpc['name']}")
        # Delete namespaces safely
        for ns in [f"{vpc['name']}-public", f"{vpc['name']}-private"]:
            run_command(f"sudo ip netns delete {ns} || true")
        # Delete bridge safely
        bridge = f"{vpc['name']}-br0"
        run_command(f"sudo ip link set {bridge} down || true")
        run_command(f"sudo ip link delete {bridge} type bridge || true")
    # Flush NAT rules
    run_command("sudo iptables -t nat -F")
    logger.info("✅ Cleanup completed. All VPCs removed.")

def start_server(namespace="Migo-vpc-1-public", port=80):
    logger.info(f"🚀 Starting HTTP server in namespace {namespace} on port {port}")
    cmd = f"sudo ip netns exec {namespace} python3 -m http.server {port} &"
    run_command(cmd)

def stop_server():
    logger.info("🛑 Stopping all HTTP servers...")
    run_command("sudo pkill -f 'http.server' || true")

def show_help():
    print("""
Usage: python3 vpcctl.py <command> [options]

Commands:
  create             Create all hardcoded VPCs
  delete             Delete all VPCs and cleanup
  start-server       Start HTTP server in a namespace (default Migo-vpc-1-public, port 80)
  stop-server        Stop all HTTP servers
  help               Show this help
""")

def main():
    if len(sys.argv) < 2:
        show_help()
        sys.exit(1)

    command = sys.argv[1].lower()

    if command == "create":
        create_vpcs()
    elif command == "delete":
        delete_vpcs()
    elif command == "start-server":
        ns = sys.argv[2] if len(sys.argv) > 2 else "Migo-vpc-1-public"
        port = sys.argv[3] if len(sys.argv) > 3 else 80
        start_server(namespace=ns, port=port)
    elif command == "stop-server":
        stop_server()
    elif command == "help":
        show_help()
    else:
        logger.error(f"❌ Unknown command: {command}")
        show_help()

if __name__ == "__main__":
    main()















