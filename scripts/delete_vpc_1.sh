#!/bin/bash
VPC_NAME="$1"
HOST_IF="$2"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "START delete_migo_vpc_1: $VPC_NAME"

# Remove NAT rule
log "Removing MASQUERADE for 10.0.0.0/16 on $HOST_IF"
iptables -t nat -D POSTROUTING -s 10.0.0.0/16 -o "$HOST_IF" -j MASQUERADE 2>&1 | tee -a "$LOGFILE" || log "Note: rule may not exist"

# Delete namespaces
log "Deleting namespaces ${VPC_NAME}-public and ${VPC_NAME}-private"
ip netns delete "${VPC_NAME}-public" 2>&1 | tee -a "$LOGFILE" || log "Note: ns may not exist"
ip netns delete "${VPC_NAME}-private" 2>&1 | tee -a "$LOGFILE" || log "Note: ns may not exist"

# Delete bridge
log "Deleting bridge ${VPC_NAME}-br0"
ip link set "${VPC_NAME}-br0" down 2>&1 | tee -a "$LOGFILE" || log "Note: bridge may not exist"
ip link delete "${VPC_NAME}-br0" type bridge 2>&1 | tee -a "$LOGFILE" || log "Note: bridge may not exist"

log "END delete_migo_vpc_1"

