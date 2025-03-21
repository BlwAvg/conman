#!/usr/bin/env bash
#
# start.sh - Start ConMan Flask service
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG_DIR="${SCRIPT_DIR}/logs"
mkdir -p "${LOG_DIR}"

echo "Starting ConMan..."
nohup python3 conman.py > "${LOG_DIR}/conman.log" 2>&1 &
echo $! > conman.pid
echo "ConMan started with PID $(cat conman.pid). Logs: ${LOG_DIR}/conman.log"
