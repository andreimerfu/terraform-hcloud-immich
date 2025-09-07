# Immich Budget Family Setup

**Ultra cost-effective Immich deployment for families: €8-12/month with unlimited photo storage**

This is a simplified, single-module Terraform configuration that deploys a complete Immich instance optimized for family use with minimal cost.

## 🎯 What You Get

- **Complete Google Photos alternative** with all features
- **AI-powered face detection and search**
- **Unlimited photo storage** via Backblaze B2 + JuiceFS (pay per use)
- **Mobile apps** for iOS and Android with auto-backup
- **Family sharing and albums**
- **HTTPS with automatic SSL certificates** (with domain)
- **Full data ownership** - your photos, your server
- **Automatic JuiceFS integration** - seamless unlimited storage

## 💰 Cost Breakdown

| Component | Monthly Cost | Details |
|-----------|--------------|---------|
| **CX22 Server** | €5.83 | 2 vCPU, 8GB RAM |
| **20GB Volume** | €0.96 | System + database + cache |
| **Backblaze B2** | ~€2.50 | 500GB photos (€0.005/GB) |
| **Total** | **€9.29** | **Complete family solution** |

*Storage scales with usage - first 10GB free, then €0.005 per GB per month*

## 🚀 Quick Deployment

### Prerequisites

1. **Hetzner Cloud account** - [console.hetzner.cloud](https://console.hetzner.cloud)
2. **Backblaze B2 account** - [backblaze.com](https://www.backblaze.com/) 
3. **SSH key** - `ssh-keygen -t ed25519`
4. **Terraform** - [terraform.io](https://terraform.io)

### 1. Setup Backblaze B2

```bash
# Create account at backblaze.com
# Create a private bucket for photos
# Generate Application Key with read/write access
# Note: Key ID, Application Key, and Bucket Name
```

### 2. Configure and Deploy

```bash
# Clone and configure
git clone <this-repo>
cd budget-family-setup

# Configure
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your tokens and keys

# Deploy
terraform init
terraform validate
terraform plan
terraform apply
```

### 3. Access Immich

```bash
# Get admin password
terraform output -raw admin_password

# Access Immich (wait ~15 minutes for setup)
# URL will be shown in terraform output
```

## 📱 Mobile App Setup

### iOS / Android
1. Download **Immich** from app store
2. Enter server URL from terraform output
3. Login with admin credentials
4. Enable automatic photo backup

## 🔧 Management Commands

```bash
# Get server IP
terraform output server_ip

# SSH to server
terraform output ssh_connection

# Check health
ssh root@<server-ip> '/usr/local/bin/immich-health-check.sh'

# View logs
ssh root@<server-ip> 'journalctl -u immich -f'

# Restart services
ssh root@<server-ip> 'systemctl restart immich'
```

## 🛠️ Validation Commands

Before deploying, validate your configuration:

```bash
# Validate Terraform syntax
terraform init
terraform validate

# Check what will be created
terraform plan

# Validate variables
terraform plan -var-file="terraform.tfvars"
```

## 📊 Scaling Examples

### Small Family (100GB photos)
- **Monthly cost**: ~€7.29
- **Storage**: €0.50/month
- **Perfect for**: Couples, minimal photo collection

### Typical Family (500GB photos) 
- **Monthly cost**: ~€9.29  
- **Storage**: €2.50/month
- **Perfect for**: Family with kids, 3-5 years of photos

### Large Family (1TB photos)
- **Monthly cost**: ~€11.79
- **Storage**: €5.00/month  
- **Perfect for**: Large families, 10+ years of photos

### Power User (2TB photos)
- **Monthly cost**: ~€16.79
- **Storage**: €10.00/month
- **Perfect for**: Photography enthusiasts

## 🔒 Security Features

- **Firewall protection** (Hetzner + UFW)
- **Fail2ban** brute-force protection  
- **SSH key authentication** only
- **HTTPS with Let's Encrypt** (with domain)
- **Automatic security updates**

## 🔧 Optional Features

### Custom Domain
```bash
# In terraform.tfvars:
domain_name = "photos.yourdomain.com"

# Point A record to server IP
# SSL certificates auto-configured
```

### Restrict SSH Access
```bash
# Find your IP
curl ifconfig.me

# In terraform.tfvars:
allowed_ssh_ips = ["YOUR.IP.ADDRESS.HERE/32"]
```

## 🆘 Troubleshooting

### Service Not Starting
```bash
ssh root@<server-ip> 'systemctl status immich'
ssh root@<server-ip> 'journalctl -u immich -n 50'
```

### Storage Issues  
```bash
ssh root@<server-ip> 'systemctl status juicefs'
ssh root@<server-ip> 'df -h /mnt/immich'
ssh root@<server-ip> 'mountpoint /mnt/immich/media'
```

### Access Issues
```bash
# Check firewall
ssh root@<server-ip> 'ufw status'

# Check if Immich is running
ssh root@<server-ip> 'docker ps'

# Check nginx (if using domain)
ssh root@<server-ip> 'systemctl status nginx'
```

## 📈 Monitoring

Basic monitoring is included:

```bash
# System health
ssh root@<server-ip> '/usr/local/bin/immich-health-check.sh'

# Resource usage
ssh root@<server-ip> 'htop'

# Storage usage
ssh root@<server-ip> 'df -h'

# Service logs
ssh root@<server-ip> 'journalctl -u immich --since "1 hour ago"'
```

## 🔄 Maintenance

### Updates
```bash
# Update containers
ssh root@<server-ip> 'cd /opt/immich && docker-compose pull && docker-compose up -d'

# System updates (automatic)
ssh root@<server-ip> 'apt update && apt upgrade -y'
```

### Backup
- **Photos**: Automatically stored in Backblaze B2
- **Database**: Stored on persistent volume
- **Config**: Stored on persistent volume

### Cleanup
```bash
# Remove old containers
ssh root@<server-ip> 'docker system prune -f'

# Check storage usage
ssh root@<server-ip> 'du -sh /mnt/immich/*'
```

## 📝 Important Notes

1. **First Setup**: Wait 15-20 minutes after `terraform apply`
2. **Admin Password**: Save it securely - needed for first login
3. **B2 Costs**: Scale with usage, estimate €0.005/GB/month
4. **SSH Keys**: Keep your private key secure
5. **Domain**: Optional but recommended for HTTPS

## 🆕 What's Different from Complex Setups

This single-module setup simplifies:

- ✅ **Single file deployment** vs complex module structure
- ✅ **Terraform validation** built-in
- ✅ **JuiceFS integration** for cheap B2 storage  
- ✅ **Automatic SSL** with Let's Encrypt
- ✅ **Health monitoring** included
- ✅ **Cost optimization** for families

## 📚 Resources

- **Immich Documentation**: [immich.app/docs](https://immich.app/docs)
- **Backblaze B2 Pricing**: [backblaze.com/b2/cloud-storage-pricing](https://www.backblaze.com/b2/cloud-storage-pricing.html)
- **Hetzner Cloud**: [docs.hetzner.com](https://docs.hetzner.com/cloud/)
- **JuiceFS**: [juicefs.com/docs](https://juicefs.com/docs/)

---

**Total setup time**: ~30 minutes  
**Monthly cost**: €8-12 for unlimited family photos  
**Complexity**: Beginner-friendly single module