#!/bin/bash
set -e

echo "=== SonarQube Installation Started ==="

# Backup configs
cp /etc/sysctl.conf /root/sysctl.conf_backup
cp /etc/security/limits.conf /root/sec_limit.conf_backup

# Kernel tuning (no ulimit here)
cat <<EOT> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
EOT
sysctl -p

# User limits
cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   65536
sonarqube   -   nproc    4096
EOT

# Install Java 17
apt-get update -y
apt-get install openjdk-17-jdk wget curl unzip -y

# Check Java
java -version

# Install PostgreSQL
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
apt-get update -y
apt-get install postgresql postgresql-contrib -y
systemctl enable postgresql
systemctl start postgresql

# Configure PostgreSQL
sudo -u postgres psql -c "CREATE USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;"

# Install SonarQube
mkdir -p /opt
cd /opt
curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-25.9.0.112764.zip
unzip -o sonarqube-25.9.0.112764.zip
mv sonarqube-25.9.0.112764 sonarqube

# Create SonarQube user
groupadd sonar || true
useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar || true
chown -R sonar:sonar /opt/sonarqube

# Configure SonarQube DB connection
cp /opt/sonarqube/conf/sonar.properties /root/sonar.properties_backup
cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT

# Create systemd service
cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonar
Group=sonar
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh console
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable sonarqube
systemctl start sonarqube

# Wait until SonarQube is up
echo "=== Waiting for SonarQube to start (this may take 1–3 minutes) ==="
until curl -s http://127.0.0.1:9000 > /dev/null; do
  sleep 10
  echo "Still starting..."
done
echo "SonarQube is now running!"

# Install Nginx reverse proxy
apt-get install nginx -y
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
cat <<EOT> /etc/nginx/sites-available/sonarqube
server {
    listen      80;
    server_name _;

    access_log  /var/log/nginx/sonar.access.log;
    error_log   /var/log/nginx/sonar.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://127.0.0.1:9000;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto http;
    }
}
EOT

ln -s /etc/nginx/sites-available/sonarqube /etc/nginx/sites-enabled/sonarqube
systemctl enable nginx
systemctl restart nginx

# Firewall rules
ufw allow 80,9000,9001/tcp || true

sudo systemctl status sonarqube

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $2}')

echo "======================================================"
echo " SonarQube installation completed successfully!"
echo " Access it via:  http://$SERVER_IP:9000/"
echo " Default login: admin / admin"
