#!/bin/bash
VPC1="$1"
VPC2="$2"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "START unpeer_migo_vpcs: $VPC1 <-> $VPC2"

PEER1="${VPC1}-to-${VPC2}"
VPC1_CIDR="10.0.0.0/16"
VPC2_CIDR="10.1.0.0/16"

log "Removing NAT exclusion rules"
iptables -t nat -D POSTROUTING -s "$VPC1_CIDR" -d "$VPC2_CIDR" -j RETURN 2>&1 | tee -a "$LOGFILE" || log "Note: rule may not exist"
iptables -t nat -D POSTROUTING -s "$VPC2_CIDR" -d "$VPC1_CIDR" -j RETURN 2>&1 | tee -a "$LOGFILE" || log "Note: rule may not exist"

log "Deleting peering veth (delete will remove both ends)"
ip link delete "$PEER1" type veth 2>&1 | tee -a "$LOGFILE" || log "Note: veth may not exist"

log "END unpeer_migo_vpcs"

