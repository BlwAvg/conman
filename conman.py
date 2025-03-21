#!/usr/bin/env python3

import os
import subprocess
import json
import re
import argparse
from flask import Flask, request, jsonify, render_template

# Webserver folder locations
app = Flask(__name__, 
            static_folder='static',
            template_folder='templates')


##############################################################################
# Utility Functions
##############################################################################

def get_active_ssh_connections():
    """
    Retrieve information about active SSH sessions using 'ss'.
    """
    try:
        result = subprocess.run(["ss", "-tanp"], capture_output=True, text=True)
        lines = result.stdout.splitlines()
        connections = []
        for line in lines:
            if "sshd" in line:
                # Example line:
                # ESTAB  0    0   192.168.1.100:22  192.168.1.50:50022 users:(("sshd",pid=1234,fd=3))
                parts = line.split()
                if len(parts) < 5:
                    continue
                state = parts[0]
                local_addr = parts[3]
                remote_addr = parts[4]
                connections.append({
                    "state": state,
                    "local_addr": local_addr,
                    "remote_addr": remote_addr
                })
        return connections
    except Exception as e:
        print(f"Failed to get active SSH connections: {e}")
        return []

def create_system_user(username):
    """
    Create a system user on Linux using 'useradd'.
    """
    try:
        subprocess.run(["sudo", "useradd", "-m", "-s", "/bin/bash", username], check=True)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error creating user {username}: {e}")
        return False

def generate_ssh_keypair(username, key_type="rsa", bits="2048"):
    """
    Generate an SSH key pair for a given user.
    Key types could include 'rsa', 'ecdsa', 'ed25519', etc.
    """
    try:
        home_dir = os.path.expanduser(f"~{username}")
        ssh_dir = os.path.join(home_dir, ".ssh")
        os.makedirs(ssh_dir, exist_ok=True)

        private_key_path = os.path.join(ssh_dir, f"id_{key_type}")
        public_key_path = f"{private_key_path}.pub"

        subprocess.run([
            "sudo", "ssh-keygen",
            "-t", key_type,
            "-b", bits,
            "-f", private_key_path,
            "-N", ""  # empty passphrase
        ], check=True)

        # Fix ownership/permissions
        subprocess.run(["sudo", "chown", "-R", f"{username}:{username}", ssh_dir], check=True)
        subprocess.run(["sudo", "chmod", "700", ssh_dir], check=True)
        subprocess.run(["sudo", "chmod", "600", private_key_path], check=True)
        subprocess.run(["sudo", "chmod", "644", public_key_path], check=True)

        return {
            "private_key_path": private_key_path,
            "public_key_path": public_key_path
        }
    except subprocess.CalledProcessError as e:
        print(f"Error generating SSH keypair for {username}: {e}")
        return None

def add_authorized_key(username, public_key):
    """
    Add a provided public key string to the user's authorized_keys file.
    """
    try:
        home_dir = os.path.expanduser(f"~{username}")
        ssh_dir = os.path.join(home_dir, ".ssh")
        authorized_keys_path = os.path.join(ssh_dir, "authorized_keys")

        os.makedirs(ssh_dir, exist_ok=True)

        with open(authorized_keys_path, "a") as akf:
            akf.write(public_key.strip() + "\n")

        # Fix ownership/permissions
        subprocess.run(["sudo", "chown", "-R", f"{username}:{username}", ssh_dir], check=True)
        subprocess.run(["sudo", "chmod", "700", ssh_dir], check=True)
        subprocess.run(["sudo", "chmod", "600", authorized_keys_path], check=True)

        return True
    except Exception as e:
        print(f"Error adding authorized key for {username}: {e}")
        return False

def open_ssh_port(port):
    """
    Modify /etc/ssh/sshd_config to include 'Port <port>' if not already present,
    open that port in firewall (ufw), then reload ssh service.
    
    Returns:
      - (True, message) on success
      - (False, error_message) on failure
    """
    # Validate port is numeric and in a reasonable range
    if not re.match(r'^\d+$', str(port)):
        return False, f"Invalid port '{port}'."
    port_num = int(port)
    if port_num < 1 or port_num > 65535:
        return False, f"Port number out of range: {port_num}"

    ssh_config_path = "/etc/ssh/sshd_config"

    # 1) Add 'Port <port>' if not exists
    try:
        with open(ssh_config_path, "r") as f:
            config_lines = f.readlines()
    except FileNotFoundError:
        return False, "sshd_config not found at /etc/ssh/sshd_config."

    # Check if port line already exists
    port_line = f"Port {port_num}\n"
    if port_line in config_lines:
        # Port is already configured
        pass
    else:
        # Append the new Port line
        try:
            with open(ssh_config_path, "a") as f:
                f.write(f"\nPort {port_num}\n")
        except Exception as e:
            return False, f"Failed to write to sshd_config: {e}"

    # 2) Open firewall port using ufw (if installed)
    #    We do a quick check for 'ufw' command. 
    #    If it doesn't exist, skip. In a real environment, handle iptables/firewalld accordingly.
    ufw_path = subprocess.run(["which", "ufw"], capture_output=True, text=True).stdout.strip()
    if ufw_path:
        # Attempt: sudo ufw allow <port_num>/tcp
        # We won't check if it's already allowed, for brevity.
        try:
            subprocess.run(["sudo", "ufw", "allow", f"{port_num}/tcp"], check=True)
        except subprocess.CalledProcessError as e:
            return False, f"Failed to open port {port_num} in ufw: {e}"

    # 3) Reload SSH to apply changes
    try:
        # Debian/Ubuntu might use 'sudo systemctl reload ssh' or 'sudo service ssh reload'
        # We'll attempt systemctl first, then fallback to service
        result = subprocess.run(["sudo", "systemctl", "reload", "ssh"], capture_output=True)
        if result.returncode != 0:
            # fallback
            subprocess.run(["sudo", "service", "ssh", "reload"], check=True)
    except subprocess.CalledProcessError as e:
        return False, f"Failed to reload ssh service: {e}"

    return True, f"SSH is now listening on port {port_num} (assuming no errors)."

##############################################################################
# Page Routes
##############################################################################

@app.route('/')
@app.route('/dashboard')
def dashboard_page():
    """
    Primary page: "Connections Dashboard"
    """
    return render_template('dashboard.html')

@app.route('/manage')
def manage_page():
    """
    Page: "Manage Connections"
    """
    return render_template('manage.html')

@app.route('/settings')
def settings_page():
    """
    Page: "Settings"
    """
    return render_template('settings.html')


##############################################################################
# REST API Endpoints
##############################################################################

@app.route('/api/connections', methods=['GET'])
def api_connections():
    """
    Return a list of active SSH connections.
    """
    connections = get_active_ssh_connections()
    return jsonify(connections)

@app.route('/api/users', methods=['POST'])
def api_create_user():
    """
    Create a new system user.
    Expected JSON: { "username": "someuser" }
    """
    data = request.json
    if not data or "username" not in data:
        return jsonify({"error": "Missing 'username'"}), 400
    
    username = data["username"]
    success = create_system_user(username)
    if success:
        return jsonify({"message": f"User '{username}' created successfully"}), 201
    else:
        return jsonify({"error": f"Failed to create user '{username}'"}), 500

@app.route('/api/keys', methods=['POST'])
def api_generate_keys():
    """
    Generate an SSH key pair for the specified user.
    Expected JSON:
      { 
        "username": "someuser",
        "key_type": "rsa" | "ecdsa" | "ed25519",
        "bits": "2048" 
      }
    """
    data = request.json
    if not data or "username" not in data:
        return jsonify({"error": "Missing 'username'"}), 400
    
    username = data["username"]
    key_type = data.get("key_type", "rsa")
    bits = data.get("bits", "2048")

    result = generate_ssh_keypair(username, key_type, bits)
    if result:
        return jsonify({
            "message": f"SSH keypair generated for user '{username}'",
            "private_key_path": result["private_key_path"],
            "public_key_path": result["public_key_path"]
        }), 201
    else:
        return jsonify({"error": f"Failed to generate keypair for '{username}'"}), 500

@app.route('/api/keys/authorized', methods=['POST'])
def api_add_authorized_key():
    """
    Add a given public key string to the user's authorized_keys.
    Expected JSON: { "username": "someuser", "public_key": "ssh-rsa AAAAB3N..." }
    """
    data = request.json
    if not data or "username" not in data or "public_key" not in data:
        return jsonify({"error": "Missing 'username' or 'public_key'"}), 400
    
    username = data["username"]
    public_key = data["public_key"]
    success = add_authorized_key(username, public_key)
    if success:
        return jsonify({"message": f"Public key added to user '{username}' authorized_keys"}), 200
    else:
        return jsonify({"error": f"Failed to add public key for '{username}'"}), 500

@app.route('/api/settings', methods=['GET', 'POST'])
def api_settings():
    """
    Simple JSON-based settings file "conman_settings.json".
    GET -> returns current settings
    POST -> updates settings
    """
    settings_file = "conman_settings.json"

    if request.method == 'GET':
        if not os.path.exists(settings_file):
            return jsonify({"theme": "default"}), 200
        with open(settings_file, 'r') as f:
            data = json.load(f)
            return jsonify(data), 200
    
    if request.method == 'POST':
        data = request.json
        if not data:
            return jsonify({"error": "No settings data provided"}), 400
        with open(settings_file, 'w') as f:
            json.dump(data, f)
        return jsonify({"message": "Settings updated"}), 200


@app.route('/api/port', methods=['POST'])
def api_open_port():
    """
    Configure a new SSH port in /etc/ssh/sshd_config and open the firewall.
    Expected JSON: { "port": "2222" }
    """
    data = request.json
    if not data or "port" not in data:
        return jsonify({"error": "Missing 'port'"}), 400

    port = data["port"]
    success, msg = open_ssh_port(port)
    if success:
        return jsonify({"message": msg}), 200
    else:
        return jsonify({"error": msg}), 500


##############################################################################
# Main Entry - This is the trash webserver.
##############################################################################
# Command-line switches to specify the server's bind address, port, and debug mode.

if __name__ == '__main__':
    # Create an argument parser for command-line options
    parser = argparse.ArgumentParser(description='Connection Manager Webserver')
    parser.add_argument('--host', default='0.0.0.0',
                        help='Host/IP to bind to (default: 0.0.0.0)')
    parser.add_argument('--port', type=int, default=5000,
                        help='Port to bind to (default: 5000)')
    parser.add_argument('--debug', action='store_true',
                        help='Enable Flask debug mode')

    args = parser.parse_args()

    # Start Flask with the specified or default host, port, and debug settings
    app.run(host=args.host, port=args.port, debug=args.debug)

    # Start Flask with the specified or default host, port, and debug settings
    app.run(host=args.host, port=args.port, debug=args.debug)