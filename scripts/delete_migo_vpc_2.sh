#!/bin/bash
VPC_NAME="$1"
HOST_IF="$2"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "START delete_migo_vpc_2: $VPC_NAME"

iptables -t nat -D POSTROUTING -s 10.1.0.0/16 -o "$HOST_IF" -j MASQUERADE 2>&1 | tee -a "$LOGFILE" || log "Note: rule may not exist"

ip netns delete "${VPC_NAME}-public" 2>&1 | tee -a "$LOGFILE" || log "Note: ns may not exist"
ip netns delete "${VPC_NAME}-private" 2>&1 | tee -a "$LOGFILE" || log "Note: ns may not exist"

ip link set "${VPC_NAME}-br0" down 2>&1 | tee -a "$LOGFILE" || log "Note: bridge may not exist"
ip link delete "${VPC_NAME}-br0" type bridge 2>&1 | tee -a "$LOGFILE" || log "Note: bridge may not exist"

log "END delete_migo_vpc_2"


