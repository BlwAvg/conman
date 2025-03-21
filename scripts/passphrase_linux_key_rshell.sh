#!/bin/bash

REMOTE_USER="your_username"
REMOTE_HOST="your_server.com"
REMOTE_PORT="19999"
LOCAL_PORT="22"
SSH_KEY="/ssj/key/location/here/.ssh/id_rsa"
SSH_OPTIONS="-o ServerAliveInterval=60 -o ServerAliveCountMax=2 -N -T -q"

# Prompt the user or set an environment variable
if [[ -z "$KEY_PASSPHRASE" ]]; then
  read -s -p "Enter SSH key passphrase: " KEY_PASSPHRASE
  echo
fi

while true
do
    echo "Attempting to establish reverse SSH tunnel..."

    expect <<EOF
      spawn ssh -i "$SSH_KEY" $SSH_OPTIONS -R $REMOTE_PORT:localhost:$LOCAL_PORT $REMOTE_USER@$REMOTE_HOST
      expect {
          "Enter passphrase for key" {
              send "$KEY_PASSPHRASE\r"
              exp_continue
          }
          eof
      }
EOF

    echo "Reverse SSH tunnel was closed or failed. Retrying in 10 seconds..."
    sleep 10
done