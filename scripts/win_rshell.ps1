# win_rshell.ps1
#
# Continually attempts a reverse SSH tunnel from Windows.
#
# To run you may need to allow it on your machine "Set-ExecutionPolicy Bypass -Scope Processf"
# or 
# powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\reverse_ssh.ps1"
#
# if there is a passphrase on the certificate then start the agent services
# Start-Service ssh-agent
# Set-Service -Name ssh-agent -StartupType 'Automatic'
#
# Then add your key
# ssh-add "$env:USERPROFILE\.ssh\id_rsa"
#

# -----------------------------------------------------------------------------
#  User-configurable settings
# -----------------------------------------------------------------------------
$REMOTE_USER  = "root"                   # The Linux user account
$REMOTE_HOST  = "linux.example.com"      # The remote Linux server (DNS or IP)
$REMOTE_PORT  = 19999                    # Remote port on the server (forward to local port 22)
$LOCAL_PORT   = 22                       # Local SSH port on Windows side
$SSH_KEY      = "$env:USERPROFILE\.ssh\id_rsa" 
    # Path to your private key in Windows (update as needed)

# SSH options (e.g., keep connection alive)
$SSH_OPTIONS  = "-o ServerAliveInterval=60 -o ServerAliveCountMax=2 -N -T -q"

# -----------------------------------------------------------------------------
#  Main loop
# -----------------------------------------------------------------------------
while ($true) {
    Write-Host "Attempting reverse SSH tunnel..."
    
    # Build the SSH command:
    # -R <remote_port>:localhost:<local_port> means "When someone connects
    #   to REMOTE_HOST:REMOTE_PORT, forward it to local localhost:LOCAL_PORT"
    # -i <key> uses the specified private key
    #
    # Example of final command:
    #   ssh -i C:\Users\MyUser\.ssh\id_rsa -o ServerAliveInterval=60 ... 
    #       -R 19999:localhost:22 root@linux.example.com
    #
    & ssh -i $SSH_KEY `
         $SSH_OPTIONS `
         -R "$REMOTE_PORT`:localhost`:$LOCAL_PORT" `
         "$REMOTE_USER`@$REMOTE_HOST"

    Write-Host "Tunnel closed or failed. Retrying in 10 seconds..."
    Start-Sleep -Seconds 10
}