#!/usr/bin/env bash
#
# stop.sh - Stop ConMan Flask service
#

# Get the directory where this script is located (conman/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logs directory under project root
LOG_DIR="${PROJECT_ROOT}/logs"
PID_FILE="${LOG_DIR}/conman.pid"

cd "$PROJECT_ROOT"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "Stopping ConMan with PID $PID..."
    kill "$PID"
    rm "$PID_FILE"
    echo "ConMan stopped."
else
    echo "No conman.pid found in ${LOG_DIR}. Is ConMan running?"
fi