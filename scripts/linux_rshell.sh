#!/bin/bash
#
# reverse_ssh.sh
# 
# This script establishes a reverse SSH tunnel back to a remote server.
# If the connection drops, it will retry after a few seconds.

# Remote SSH user and server
REMOTE_USER="your_username"
REMOTE_HOST="your_server.com"

# Remote port on the server that will be forwarded back to the client.
# For example: 19999 means that SSH to your_server.com on port 19999
# will connect to the client machine's port 22.
REMOTE_PORT="19999"

# Local SSH port to be exposed (usually 22 for SSH)
LOCAL_PORT="22"

# Optional: Path to your private key for passwordless login
SSH_KEY="/home/your_username/.ssh/id_rsa"

# Optional SSH options for better stability
SSH_OPTIONS="-o ServerAliveInterval=60 -o ServerAliveCountMax=2 -N -T -q"

# The loop will keep trying to reconnect if the tunnel is closed
while true
do
    echo "Attempting to establish reverse SSH tunnel..."
    ssh -i "$SSH_KEY" \
        $SSH_OPTIONS \
        -R $REMOTE_PORT:localhost:$LOCAL_PORT \
        $REMOTE_USER@$REMOTE_HOST
    
    echo "Reverse SSH tunnel was closed or failed. Retrying in 10 seconds..."
    sleep 10
done