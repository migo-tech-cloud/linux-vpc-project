#!/bin/bash
LOGDIR="logs"
LOGFILE="$LOGDIR/vpcctl.log"
mkdir -p "$LOGDIR"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"; }

log "Stopping HTTP servers"
pkill -f "python3 -m http.server" 2>&1 | tee -a "$LOGFILE" || log "No http.server processes found"
log "Stopped HTTP servers"
