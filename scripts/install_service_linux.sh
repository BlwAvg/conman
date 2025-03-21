#!/usr/bin/env bash
#
# install_service.sh - Create and enable a systemd service for ConMan.
#

# Path to the systemd unit file we’ll create
SERVICE_FILE="/etc/systemd/system/conman.service"

# Path to your conman "start.sh" script
# Adjust this to the actual, absolute path on your server:
CONMAN_START_SCRIPT="/path/to/conman/scripts/start.sh --host 127.0.0.1 --port 5000 --debug y"

# Linux user to run ConMan as:
RUN_AS_USER="root"

# (Optional) Working directory, if you want to enforce it:
WORKING_DIR="/path/to/conman"

if [ ! -f "$CONMAN_START_SCRIPT" ]; then
  echo "Error: start.sh not found at '$CONMAN_START_SCRIPT'"
  exit 1
fi

echo "Creating systemd service file at $SERVICE_FILE ..."

# Create the unit file
sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=ConMan Service
After=network.target

[Service]
Type=simple
User=$RUN_AS_USER
WorkingDirectory=$WORKING_DIR
ExecStart=/usr/bin/env bash $CONMAN_START_SCRIPT
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF"

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling ConMan to start on boot..."
sudo systemctl enable conman

echo "Starting ConMan service..."
sudo systemctl start conman

echo "Systemd service 'conman' installed and started."
echo "Check status with:  sudo systemctl status conman"
echo "View logs with:     sudo journalctl -u conman"
