#!/usr/bin/env bash
#
# stop.sh - Stop ConMan Flask service
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ -f conman.pid ]; then
    PID=$(cat conman.pid)
    echo "Stopping ConMan with PID $PID..."
    kill "$PID"
    rm conman.pid
    echo "ConMan stopped."
else
    echo "No conman.pid found. Is ConMan running?"
fi
