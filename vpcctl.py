#!/usr/bin/env python3
import subprocess
import sys
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

VPCS = [
    {"name": "Migo-vpc-1", "bridge": "Migo-vpc-1-br0"},
    {"name": "Migo-vpc-2", "bridge": "Migo-vpc-2-br0"},
]

HOST_IF = "enX0"  # replace with your actual host interface


def run(cmd, check=True):
    logging.info(f"🔹 Running command: {cmd}")
    result = subprocess.run(cmd, shell=True)
    if check and result.returncode != 0:
        logging.error(f"❌ Command failed with exit code {result.returncode}")
    return result.returncode


def create_vpcs():
    logging.info("🚀 Starting VPC creation process...")
    for vpc in VPCS:
        script = f"scripts/create_{vpc['name'].lower().replace('-', '_')}.sh"
        logging.info(f"Creating {vpc['name']} using {script}")
        run(f"bash {script} {vpc['name']} {HOST_IF}", check=False)
    logging.info("✅ All VPCs created successfully!")


def delete_vpcs():
    logging.info("🧹 Cleaning up all VPCs...")
    for vpc in VPCS:
        logging.info(f"🔹 Deleting VPC: {vpc['name']}")
        # Delete namespaces
        for ns in ["public", "private"]:
            run(f"sudo ip netns delete {vpc['name']}-{ns}", check=False)
        # Delete bridge
        run(f"sudo ip link set {vpc['bridge']} down", check=False)
        run(f"sudo ip link delete {vpc['bridge']} type bridge", check=False)
    # Flush NAT table
    run("sudo iptables -t nat -F", check=False)
    logging.info("✅ Cleanup completed. All VPCs removed.")


def peer_vpcs():
    logging.info("🔗 Setting up VPC peering between Migo-vpc-1 and Migo-vpc-2...")

    # Example: Add static routes for peering
    # Adjust subnets accordingly (assuming /16 ranges)
    vpc1_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    vpc2_subnets = ["10.1.1.0/24", "10.1.2.0/24"]

    # Add routes in vpc1
    for subnet in vpc2_subnets:
        run(f"sudo ip netns exec Migo-vpc-1-public ip route add {subnet} via 10.0.0.1", check=False)
        run(f"sudo ip netns exec Migo-vpc-1-private ip route add {subnet} via 10.0.0.1", check=False)

    # Add routes in vpc2
    for subnet in vpc1_subnets:
        run(f"sudo ip netns exec Migo-vpc-2-public ip route add {subnet} via 10.1.0.1", check=False)
        run(f"sudo ip netns exec Migo-vpc-2-private ip route add {subnet} via 10.1.0.1", check=False)

    # Update NAT rules: exclude peering traffic
    run(f"sudo iptables -t nat -A POSTROUTING -o {HOST_IF} -s 10.0.0.0/16 -d 10.1.0.0/16 -j ACCEPT", check=False)
    run(f"sudo iptables -t nat -A POSTROUTING -o {HOST_IF} -s 10.1.0.0/16 -d 10.0.0.0/16 -j ACCEPT", check=False)
    logging.info("✅ VPC peering setup completed.")


def start_server(namespace="Migo-vpc-1-public", port=80):
    logging.info(f"🚀 Starting HTTP server in {namespace} on port {port}...")
    run(f"sudo ip netns exec {namespace} python3 -m http.server {port} &", check=False)


def stop_server():
    logging.info("🛑 Stopping all HTTP servers...")
    run("sudo pkill -f http.server", check=False)


def show_help():
    print(
        """
Usage: python3 vpcctl.py <command> [options]

Commands:
  create             Create all hardcoded VPCs
  delete             Delete all VPCs and cleanup
  peer               Set up VPC peering between Migo-vpc-1 and Migo-vpc-2
  start-server       Start HTTP server in a namespace (default Migo-vpc-1-public, port 80)
  stop-server        Stop all HTTP servers
  help               Show this help
"""
    )


if __name__ == "__main__":
    if len(sys.argv) < 2:
        show_help()
        sys.exit(1)

    cmd = sys.argv[1].lower()

    if cmd == "create":
        create_vpcs()
    elif cmd == "delete":
        delete_vpcs()
    elif cmd == "peer":
        peer_vpcs()
    elif cmd == "start-server":
        start_server()
    elif cmd == "stop-server":
        stop_server()
    elif cmd == "help":
        show_help()
    else:
        logging.error(f"❌ Unknown command: {cmd}")
        show_help()
        sys.exit(1)













