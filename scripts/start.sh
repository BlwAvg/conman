#!/usr/bin/env bash
#
# start.sh - Start ConMan Flask service
#

# Get the directory where this script is located (conman/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Make sure we run from the project root so relative paths work
cd "$PROJECT_ROOT"

# Logs directory under project root
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "${LOG_DIR}"

echo "Starting ConMan..."
nohup python3 conman.py > "${LOG_DIR}/conman.log" 2>&1 &
echo $! > "${LOG_DIR}/conman.pid"
echo "ConMan started with PID $(cat "${LOG_DIR}/conman.pid"). Logs: ${LOG_DIR}/conman.log"

