#!/bin/bash
#
# reverse_ssh_autossh.sh

REMOTE_USER="your_username"
REMOTE_HOST="your_server.com"
REMOTE_PORT="19999"
LOCAL_PORT="22"
SSH_KEY="/home/your_username/.ssh/id_rsa"

# autossh will monitor the connection; -M 0 disables autossh's own monitoring port
autossh -M 0 \
    -i "$SSH_KEY" \
    -N -T -q \
    -o ServerAliveInterval=60 -o ServerAliveCountMax=2 \
    -R $REMOTE_PORT:localhost:$LOCAL_PORT \
    $REMOTE_USER@$REMOTE_HOST
