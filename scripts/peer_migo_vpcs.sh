#!/bin/bash
VPC1="$1"
VPC2="$2"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "START peer_migo_vpcs: $VPC1 <-> $VPC2"

PEER1="${VPC1}-to-${VPC2}"
PEER2="${VPC2}-to-${VPC1}"
VPC1_CIDR="10.0.0.0/16"
VPC2_CIDR="10.1.0.0/16"

log "Creating peering veth pair $PEER1 <-> $PEER2"
ip link add "$PEER1" type veth peer name "$PEER2" 2>&1 | tee -a "$LOGFILE" || log "Note: veth pair may already exist"

log "Attaching to bridges"
ip link set "$PEER1" master "${VPC1}-br0" 2>&1 | tee -a "$LOGFILE"
ip link set "$PEER2" master "${VPC2}-br0" 2>&1 | tee -a "$LOGFILE"
ip link set "$PEER1" up 2>&1 | tee -a "$LOGFILE"
ip link set "$PEER2" up 2>&1 | tee -a "$LOGFILE"

log "Adding routes and NAT exclusions"
iptables -t nat -I POSTROUTING 1 -s "$VPC1_CIDR" -d "$VPC2_CIDR" -j RETURN 2>&1 | tee -a "$LOGFILE" || log "Note: rule may already exist"
iptables -t nat -I POSTROUTING 1 -s "$VPC2_CIDR" -d "$VPC1_CIDR" -j RETURN 2>&1 | tee -a "$LOGFILE" || log "Note: rule may already exist"

log "END peer_migo_vpcs"




