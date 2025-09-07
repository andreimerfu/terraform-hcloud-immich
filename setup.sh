#!/bin/bash
# ================================================================
# Immich Budget Family Setup Script
# ================================================================

set -euo pipefail

# Configuration from environment variables (set by Terraform)
# These are set as environment variables by the Terraform provisioner

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/immich-setup.log
}

log "Starting Immich Budget Family setup"

# ================================================================
# System Setup
# ================================================================

log "Configuring system"

# Set timezone
timedatectl set-timezone Europe/Berlin

# Configure firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80
ufw allow 443
ufw allow 2283
ufw --force enable

# Configure fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# ================================================================
# Volume Setup
# ================================================================

log "Setting up storage volume"

# Format and mount the volume
if ! blkid "$VOLUME_DEVICE" >/dev/null 2>&1; then
    mkfs.ext4 -F "$VOLUME_DEVICE"
fi

# Create mount point and mount if not already mounted
mkdir -p /mnt/immich

# Check if already mounted
if ! mountpoint -q /mnt/immich; then
    mount "$VOLUME_DEVICE" /mnt/immich
fi

# Add to fstab if not already there
if ! grep -q "/mnt/immich" /etc/fstab; then
    echo "$VOLUME_DEVICE /mnt/immich ext4 defaults 0 2" >> /etc/fstab
fi

# Create directory structure
mkdir -p /mnt/immich/{data,database,cache,config}
chown -R root:root /mnt/immich
chmod -R 755 /mnt/immich

log "Volume setup completed"

# ================================================================
# Docker Installation
# ================================================================

log "Installing Docker"

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker
systemctl enable docker
systemctl start docker

log "Docker installation completed"

# ================================================================
# JuiceFS Installation and Setup for Backblaze B2 Storage
# ================================================================

log "Installing JuiceFS for unlimited B2 storage"

# Install JuiceFS
curl -sSL https://d.juicefs.com/install | sh -

# Create JuiceFS cache directory
mkdir -p /mnt/immich/cache/juicefs-cache

# Format JuiceFS filesystem with Backblaze B2
log "Formatting JuiceFS filesystem with Backblaze B2"
export AWS_ACCESS_KEY_ID="$BACKBLAZE_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$BACKBLAZE_KEY"

/usr/local/bin/juicefs format \
  --storage s3 \
  --bucket "https://s3.$BACKBLAZE_REGION.backblazeb2.com/$BACKBLAZE_BUCKET" \
  sqlite3:///mnt/immich/cache/juicefs.db \
  immich-photos

# Create JuiceFS mount point
mkdir -p /mnt/immich/juicefs

# Mount JuiceFS
log "Mounting JuiceFS filesystem"
/usr/local/bin/juicefs mount \
  sqlite3:///mnt/immich/cache/juicefs.db \
  /mnt/immich/juicefs \
  --cache-dir /mnt/immich/cache/juicefs-cache \
  -d

# Create systemd service for JuiceFS
log "Creating JuiceFS systemd service"
cat > /etc/systemd/system/juicefs.service << EOF
[Unit]
Description=JuiceFS Mount for Immich
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
User=root
Group=root
Environment=AWS_ACCESS_KEY_ID=$BACKBLAZE_KEY_ID
Environment=AWS_SECRET_ACCESS_KEY=$BACKBLAZE_KEY
ExecStartPre=/bin/mkdir -p /mnt/immich/juicefs
ExecStartPre=/bin/mkdir -p /mnt/immich/cache/juicefs-cache
ExecStart=/usr/local/bin/juicefs mount sqlite3:///mnt/immich/cache/juicefs.db /mnt/immich/juicefs --cache-dir /mnt/immich/cache/juicefs-cache -d
ExecStop=/bin/fusermount -u /mnt/immich/juicefs
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable JuiceFS service
systemctl daemon-reload
systemctl enable juicefs

# Create initial directory structure in JuiceFS
mkdir -p /mnt/immich/juicefs/{library,upload,profile,thumbs,backups,encoded-video}
chown -R 1001:1001 /mnt/immich/juicefs

log "JuiceFS setup completed - unlimited photo storage ready"

# ================================================================
# Immich Installation
# ================================================================

log "Installing Immich"

# Create Immich directory
mkdir -p /opt/immich

# Create docker-compose.yml
cat > /opt/immich/docker-compose.yml << EOF
version: '3.8'

services:
  immich-server:
    container_name: immich_server
    image: ghcr.io/immich-app/immich-server:release
    command: [ "start.sh", "immich" ]
    volumes:
      - /mnt/immich/juicefs:/usr/src/app/upload
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DB_HOSTNAME=immich_postgres
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_DATABASE_NAME=immich
      - REDIS_HOSTNAME=immich_redis
      - IMMICH_HOST=0.0.0.0
      - IMMICH_PORT=3001
    depends_on:
      - redis
      - database
    restart: always
    ports:
      - 2283:3001

  immich-microservices:
    container_name: immich_microservices
    image: ghcr.io/immich-app/immich-server:release
    command: [ "start.sh", "microservices" ]
    volumes:
      - /mnt/immich/juicefs:/usr/src/app/upload
      - /etc/localtime:/etc/localtime:ro
    environment:
      - DB_HOSTNAME=immich_postgres
      - DB_USERNAME=postgres
      - DB_PASSWORD=postgres
      - DB_DATABASE_NAME=immich
      - REDIS_HOSTNAME=immich_redis
    depends_on:
      - redis
      - database
    restart: always

  immich-machine-learning:
    container_name: immich_machine_learning
    image: ghcr.io/immich-app/immich-machine-learning:release
    volumes:
      - /mnt/immich/cache/model-cache:/cache
    restart: always

  redis:
    container_name: immich_redis
    image: redis:6.2-alpine
    restart: always

  database:
    container_name: immich_postgres
    image: tensorchord/pgvecto-rs:pg14-v0.2.0
    environment:
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_DB=immich
      - PG_DATA=/var/lib/postgresql/data
    volumes:
      - /mnt/immich/database:/var/lib/postgresql/data
    restart: always

EOF

# Create systemd service for Immich
cat > /etc/systemd/system/immich.service << EOF
[Unit]
Description=Immich
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
WorkingDirectory=/opt/immich
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# Verify JuiceFS is mounted before starting Immich
log "Verifying JuiceFS mount"
if ! mountpoint -q /mnt/immich/juicefs; then
    log "ERROR: JuiceFS not mounted, attempting to remount"
    /usr/local/bin/juicefs mount \
      sqlite3:///mnt/immich/cache/juicefs.db \
      /mnt/immich/juicefs \
      --cache-dir /mnt/immich/cache/juicefs-cache \
      -d
    sleep 5
fi

# Enable and start Immich
systemctl daemon-reload
systemctl enable immich
systemctl start immich

log "Immich installation completed with JuiceFS storage"

# Clean up old media files to save space (photos are now in JuiceFS/B2)
log "Cleaning up redundant local media files"
if [ -d "/mnt/immich/media" ] && mountpoint -q /mnt/immich/juicefs; then
    rm -rf /mnt/immich/media/upload/* 2>/dev/null || true
    rm -rf /mnt/immich/media/thumbs/* 2>/dev/null || true
    log "Local media cleanup completed - photos remain safe in Backblaze B2"
fi

# ================================================================
# SSL Configuration (if domain provided)
# ================================================================

if [[ "$ENABLE_HTTPS" == "true" && -n "$DOMAIN_NAME" ]]; then
    log "Configuring SSL with Let's Encrypt"
    
    # Install certbot
    apt-get update
    apt-get install -y certbot
    
    # Get SSL certificate
    certbot certonly --standalone --non-interactive --agree-tos --email "$ADMIN_EMAIL" -d "$DOMAIN_NAME"
    
    # Install nginx for reverse proxy
    apt-get install -y nginx
    
    # Create nginx configuration
    cat > /etc/nginx/sites-available/immich << EOF
server {
    listen 80;
    server_name $DOMAIN_NAME;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN_NAME;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
    
    client_max_body_size 50000M;
    
    location / {
        proxy_pass http://localhost:2283;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_buffering off;
    }
}
EOF
    
    # Enable site
    ln -sf /etc/nginx/sites-available/immich /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test and reload nginx
    nginx -t && systemctl reload nginx
    
    # Setup auto-renewal
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew --quiet") | crontab -
    
    log "SSL configuration completed"
fi

# ================================================================
# Health Check Script
# ================================================================

log "Creating health check script"

cat > /usr/local/bin/immich-health-check.sh << EOF
#!/bin/bash

echo "=== Immich Health Check ==="
echo "Date: $(date)"
echo

echo "=== Services Status ==="
systemctl is-active immich
systemctl is-active juicefs
systemctl is-active docker
echo

echo "=== Container Status ==="
docker ps --format "table {{.Names}}\t{{.Status}}"
echo

echo "=== Storage Usage ==="
df -h /mnt/immich
echo

echo "=== JuiceFS Status ==="
if mountpoint -q /mnt/immich/juicefs; then
    echo "JuiceFS: Mounted"
    /usr/local/bin/juicefs info /mnt/immich/juicefs 2>/dev/null || echo "JuiceFS info unavailable"
else
    echo "JuiceFS: NOT MOUNTED"
fi
echo

echo "=== Memory Usage ==="
free -h
echo

echo "=== Recent Logs ==="
journalctl -u immich --since "1 hour ago" --no-pager -n 5
EOF

chmod +x /usr/local/bin/immich-health-check.sh

# ================================================================
# Final Setup
# ================================================================

log "Finalizing setup"

# Wait for services to be ready
sleep 30

# Create a simple status file
cat > /opt/immich/status.txt << EOF
Immich Budget Family Setup
=========================
Deployed: $(date)
Project: $PROJECT_NAME
Domain: $${DOMAIN_NAME:-"IP Access Only"}
Admin Email: $ADMIN_EMAIL

Services:
- Immich: http://localhost:2283
- JuiceFS: /mnt/immich/juicefs (unlimited via B2)
- PostgreSQL: Container
- Redis: Container

Storage:
- Local Volume: /mnt/immich (20GB) - System & Database
- Media Storage: Backblaze B2 via JuiceFS (unlimited)
- JuiceFS Cache: /mnt/immich/cache/juicefs-cache

Health Check: /usr/local/bin/immich-health-check.sh
EOF

# Set up log rotation
cat > /etc/logrotate.d/immich << EOF
/var/log/immich-setup.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
}
EOF

log "Setup completed successfully!"
log "Immich should be accessible at: $${DOMAIN_NAME:+https://$DOMAIN_NAME}$${DOMAIN_NAME:-http://$(curl -s ifconfig.me):2283}"
log "Check status with: /usr/local/bin/immich-health-check.sh"

# Final health check
/usr/local/bin/immich-health-check.sh || true

log "All done! Immich Budget Family setup completed."