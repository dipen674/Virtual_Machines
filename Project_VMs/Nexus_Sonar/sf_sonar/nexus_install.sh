#!/bin/bash

# Exit on error
set -e

# Define Nexus version and download URL
NEXUS_VERSION="3.84.1-01"
NEXUS_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-linux-x86_64.tar.gz"
NEXUS_DIR="nexus-$NEXUS_VERSION"

echo "Starting Nexus installation..."

# Install dependencies
echo "Installing Java and dependencies..."
sudo apt update
sudo apt install openjdk-17-jdk wget -y

# Create directories
echo "Creating directories..."
sudo mkdir -p /opt/nexus/
sudo mkdir -p /tmp/nexus/

# Download and extract Nexus
echo "Downloading Nexus..."
cd /tmp/nexus/
sudo wget $NEXUS_URL -O nexus.tar.gz
echo "Extracting Nexus..."
sudo tar xzvf nexus.tar.gz
sudo rm -f /tmp/nexus/nexus.tar.gz

# Move Nexus to installation directory
echo "Installing Nexus to /opt/nexus/"
sudo rsync -avzh /tmp/nexus/ /opt/nexus/

# Create nexus user
echo "Creating nexus user..."
if id "nexus" &>/dev/null; then
    echo "User nexus already exists."
else
    sudo useradd nexus
fi

# Set ownership
echo "Setting permissions..."
sudo chown -R nexus:nexus /opt/nexus

# Create systemd service
echo "Creating systemd service..."
cat <<EOT | sudo tee /etc/systemd/system/nexus.service > /dev/null
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUS_DIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUS_DIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Configure Nexus to run as nexus user
echo "Configuring Nexus..."
sudo sh -c "echo 'run_as_user=\"nexus\"' > /opt/nexus/$NEXUS_DIR/bin/nexus.rc"

# Enable and start Nexus service
echo "Starting Nexus service..."
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

# Wait for Nexus to start
echo "Waiting for Nexus to start (this may take a few minutes)..."
sleep 30

sudo systemctl status nexus

# Check if Nexus is running
if systemctl is-active --quiet nexus; then
    # Get server IP address
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    
    echo "=================================================="
    echo "Nexus installation completed successfully!"
    echo "Nexus is now running on: http://$IP_ADDRESS:8081"
    echo "=================================================="
    echo "Default credentials:"
    echo "Username: admin"
    echo "Password: Check /opt/nexus/$NEXUS_DIR/sonatype-work/nexus3/admin.password"
    echo "=================================================="
else
    echo "Nexus service failed to start. Please check logs with: journalctl -u nexus.service -b"
    exit 1
fi

# Clean up
sudo rm -rf /tmp/nexus/
echo "Temporary files cleaned up."
    error_log   /var/log/nginx/sonar.error.log;