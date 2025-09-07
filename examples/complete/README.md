# Complete Immich Deployment Example

This example demonstrates how to deploy a complete Immich family photo server with unlimited storage using the terraform-immich-hetzner module.

## Features

- **Cost-Optimized**: €8-12/month for unlimited family photos
- **Complete Google Photos Alternative**: AI-powered face detection, search, mobile apps
- **Unlimited Storage**: S3-compatible storage integration via JuiceFS filesystem (optimized for Backblaze B2)
- **Automatic SSL**: Let's Encrypt certificates when domain is provided
- **Family Ready**: Multi-user support with sharing and albums

## Quick Start

1. **Prerequisites**
   - Hetzner Cloud account and API token
   - SSH key pair (`ssh-keygen -t ed25519`)
   - Backblaze B2 account with private bucket
   - Terraform >= 1.0

2. **Configure**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your credentials
   ```

3. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Access**
   ```bash
   # Get admin password
   terraform output -raw admin_password
   
   # Access URL is shown in output
   terraform output immich_url
   ```

## Cost Breakdown

| Component | Monthly Cost | Details |
|-----------|--------------|---------|
| **CX22 Server** | €5.83 | 2 vCPU, 8GB RAM |
| **20GB Volume** | €0.96 | System + database + cache |
| **Backblaze B2** | ~€2.50 | 500GB photos (€0.005/GB) |
| **Total** | **€9.29** | **Complete family solution** |

*Storage scales with usage - first 10GB free*

## Management

```bash
# Check system health
ssh root@$(terraform output -raw server_ip) '/usr/local/bin/immich-health-check.sh'

# View logs
ssh root@$(terraform output -raw server_ip) 'journalctl -u immich -f'

# Restart services
ssh root@$(terraform output -raw server_ip) 'systemctl restart immich'
```

## Mobile Apps

1. Download **Immich** from iOS/Android app store
2. Enter server URL from terraform output
3. Login with admin credentials
4. Enable automatic photo backup

Your photos will be safely stored in Backblaze B2 with unlimited capacity!