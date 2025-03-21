#!/usr/bin/env bash
#
# start.sh - Start ConMan Flask service
#

# Get the directory where this script is located (conman/scripts)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The project root (parent of scripts directory)
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Ensure we run from the project root so relative paths work
cd "$PROJECT_ROOT"

# Logs directory under project root
LOG_DIR="${PROJECT_ROOT}/logs"
mkdir -p "${LOG_DIR}"

# Prompt for host IP (default: 0.0.0.0)
read -p "Enter IP to bind [0.0.0.0]: " BIND_IP
BIND_IP="${BIND_IP:-0.0.0.0}"

# Prompt for port (default: 5000)
read -p "Enter port [5000]: " BIND_PORT
BIND_PORT="${BIND_PORT:-5000}"

# Prompt for debug mode
read -p "Enable debug mode? [y/N]: " DEBUG_CHOICE
if [[ "$DEBUG_CHOICE" =~ ^[Yy]$ ]]; then
    DEBUG_FLAG="--debug"
else
    DEBUG_FLAG=""
fi

echo "Starting ConMan on IP ${BIND_IP}, port ${BIND_PORT}, debug = $( [ -n "$DEBUG_FLAG" ] && echo 'ON' || echo 'OFF')"

nohup python3 conman.py \
    --host "${BIND_IP}" \
    --port "${BIND_PORT}" \
    ${DEBUG_FLAG} \
    > "${LOG_DIR}/conman.log" 2>&1 &

echo $! > "${LOG_DIR}/conman.pid"
echo "ConMan started with PID $(cat "${LOG_DIR}/conman.pid"). Logs: ${LOG_DIR}/conman.log"


