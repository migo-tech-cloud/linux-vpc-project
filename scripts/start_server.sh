#!/bin/bash
# Usage: bash start_server.sh <namespace> <port>
NS="${1:-Migo-vpc-1-public}"
PORT="${2:-80}"
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "Starting HTTP server in $NS on port $PORT"
ip netns exec "$NS" nohup python3 -m http.server "$PORT" >"$LOGDIR/${NS}_http.log" 2>&1 &
sleep 1
log "Server started (check $LOGDIR/${NS}_http.log) with PID $!"
