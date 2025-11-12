#!/bin/bash
POLICY_FILE="./config/policies.json"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

if [ ! -f "$POLICY_FILE" ]; then
  log "ERROR: Policy file not found: $POLICY_FILE"
  exit 1
fi

log "START apply_firewall: reading $POLICY_FILE"

# iterate keys (namespace names)
for NS in $(jq -r 'keys[]' "$POLICY_FILE"); do
  log "Applying rules for namespace $NS"
  # make sure namespace exists
  if ! ip netns list | grep -q "^$NS"; then
    log "WARNING: namespace $NS not present; skipping"
    continue
  fi

  # flush existing rules
  ip netns exec "$NS" iptables -F 2>&1 | tee -a "$LOGFILE"

  # ingress rules
  jq -c ".\"$NS\".ingress[]" "$POLICY_FILE" 2>/dev/null | while read -r RULE; do
    PORT=$(echo "$RULE" | jq -r '.port')
    PROTO=$(echo "$RULE" | jq -r '.protocol')
    ACTION=$(echo "$RULE" | jq -r '.action')
    if [ "$ACTION" == "allow" ]; then
      log "Allowing ingress $PROTO port $PORT on $NS"
      ip netns exec "$NS" iptables -A INPUT -p "$PROTO" --dport "$PORT" -j ACCEPT 2>&1 | tee -a "$LOGFILE"
    else
      log "Dropping ingress $PROTO port $PORT on $NS"
      ip netns exec "$NS" iptables -A INPUT -p "$PROTO" --dport "$PORT" -j DROP 2>&1 | tee -a "$LOGFILE"
    fi
  done

  # default deny
  log "Setting default DROP policy for INPUT on $NS"
  ip netns exec "$NS" iptables -A INPUT -j DROP 2>&1 | tee -a "$LOGFILE"
done

log "END apply_firewall"


