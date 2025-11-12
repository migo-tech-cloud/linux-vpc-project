#!/bin/bash
# create_migo_vpc_1.sh <VPC_NAME> <HOST_INTERFACE>
VPC_NAME="$1"
HOST_IF="$2"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "START create_migo_vpc_1: $VPC_NAME on host-if $HOST_IF"

BR_NAME="${VPC_NAME}-br0"
PUB_NS="${VPC_NAME}-public"
PRIV_NS="${VPC_NAME}-private"

BR_IP="10.0.0.1/16"
PUB_IP="10.0.1.2/16"
PRIV_IP="10.0.2.2/16"

# Create / reset bridge
log "Creating bridge $BR_NAME ($BR_IP)"
ip link add "$BR_NAME" type bridge 2>&1 | tee -a "$LOGFILE" || log "Note: bridge create may already exist"
ip addr add "$BR_IP" dev "$BR_NAME" 2>&1 | tee -a "$LOGFILE" || log "Note: addr add may already exist"
ip link set "$BR_NAME" up 2>&1 | tee -a "$LOGFILE"

# Create namespaces
log "Creating namespaces $PUB_NS and $PRIV_NS"
ip netns add "$PUB_NS" 2>&1 | tee -a "$LOGFILE" || log "Note: namespace may already exist"
ip netns add "$PRIV_NS" 2>&1 | tee -a "$LOGFILE" || log "Note: namespace may already exist"

# Create veth pairs
log "Creating veth pairs for public/private"
ip link add veth-pub type veth peer name veth-pub-br 2>&1 | tee -a "$LOGFILE" || log "Note: veth-pub may already exist"
ip link add veth-priv type veth peer name veth-priv-br 2>&1 | tee -a "$LOGFILE" || log "Note: veth-priv may already exist"

# Attach veths
log "Attaching veths to namespaces and bridge"
ip link set veth-pub netns "$PUB_NS" 2>&1 | tee -a "$LOGFILE" || log "Note: possibly already set"
ip link set veth-priv netns "$PRIV_NS" 2>&1 | tee -a "$LOGFILE" || log "Note: possibly already set"
ip link set veth-pub-br master "$BR_NAME" 2>&1 | tee -a "$LOGFILE"
ip link set veth-priv-br master "$BR_NAME" 2>&1 | tee -a "$LOGFILE"
ip link set veth-pub-br up 2>&1 | tee -a "$LOGFILE"
ip link set veth-priv-br up 2>&1 | tee -a "$LOGFILE"

# Assign IPs inside namespaces
log "Assigning IPs inside namespaces: public=$PUB_IP private=$PRIV_IP"
ip -n "$PUB_NS" addr add "$PUB_IP" dev veth-pub 2>&1 | tee -a "$LOGFILE" || log "Note: IP may already exist"
ip -n "$PRIV_NS" addr add "$PRIV_IP" dev veth-priv 2>&1 | tee -a "$LOGFILE" || log "Note: IP may already exist"

ip -n "$PUB_NS" link set veth-pub up 2>&1 | tee -a "$LOGFILE"
ip -n "$PRIV_NS" link set veth-priv up 2>&1 | tee -a "$LOGFILE"

# Default routes
GW="${BR_IP%/*}"
GW="${GW%.*}.1"
log "Adding default routes via $GW"
ip -n "$PUB_NS" route add default via "$GW" 2>&1 | tee -a "$LOGFILE" || log "Note: route may already exist"
ip -n "$PRIV_NS" route add default via "$GW" 2>&1 | tee -a "$LOGFILE" || log "Note: route may already exist"

# IP forwarding + NAT
log "Enabling IP forwarding"
sysctl -w net.ipv4.ip_forward=1 2>&1 | tee -a "$LOGFILE"

log "Applying MASQUERADE for public subnet"
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o "$HOST_IF" -j MASQUERADE 2>&1 | tee -a "$LOGFILE" || log "Note: iptables rule may already exist"

log "END create_migo_vpc_1"









