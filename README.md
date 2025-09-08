# Terraform Module: Immich on Hetzner Cloud

<div align="center">
  <br><br>
  <img src="https://immich.app/img/immich-logo-inline-light.png" alt="Immich" width="300">
  <br><br>
  <a href="https://registry.terraform.io/modules/andreimerfu/immich/hcloud/latest">
    <img src="https://img.shields.io/badge/terraform-registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry">
  </a>
  <a href="https://github.com/andreimerfu/terraform-hcloud-immich/releases">
    <img src="https://img.shields.io/github/v/release/andreimerfu/terraform-hcloud-immich?style=for-the-badge&logo=github" alt="GitHub release">
  </a>
  <a href="https://github.com/andreimerfu/terraform-hcloud-immich/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/andreimerfu/terraform-hcloud-immich/ci.yml?style=for-the-badge&logo=github-actions&logoColor=white" alt="GitHub Workflow Status">
  </a>
  <a href="https://www.terraform.io/">
    <img src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform">
  </a>
  <a href="https://www.hetzner.com/cloud">
    <img src="https://img.shields.io/badge/hetzner-%23d50c2d.svg?style=for-the-badge&logo=hetzner&logoColor=white" alt="Hetzner Cloud">
  </a>
</div>

**Cost-effective Immich deployment for families: €7-10/month with unlimited photo storage**

This Terraform module deploys a complete Immich instance on Hetzner Cloud, optimized for family use with minimal operational costs. Features unlimited photo storage via Backblaze B2 integration.

## 🎯 What You Get

- **Complete Google Photos alternative** with all features
- **AI-powered face detection and search**
- **Unlimited photo storage** via S3-compatible storage + JuiceFS (optimized for Backblaze B2)
- **Mobile apps** for iOS and Android with auto-backup
- **Family sharing and albums**
- **HTTPS with automatic SSL certificates** (with domain)
- **Full data ownership** - your photos, your server

## 💰 Cost Breakdown

| Component | Monthly Cost | Details |
|-----------|--------------|---------|
| **CX22 Server** | €3.79 | 2 vCPU, 4GB RAM |
| **20GB Volume** | €0.88 | System + database + cache |
| **S3 Storage** | ~€2.75 | 500GB photos (Backblaze B2: €0.0055/GB) |
| **Total** | **€7.42** | **Complete family solution** |

*Storage scales with usage - first 10GB free*

## Usage

```hcl
module "immich-hetzner" {
  source  = "andreimerfu/hcloud-immich/hcloud"
  version = "~> 1.0"

  # Required variables
  hcloud_token                    = var.hcloud_token
  ssh_public_keys                = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI..."]
  s3_access_key_id               = var.s3_access_key_id
  s3_secret_access_key           = var.s3_secret_access_key
  s3_bucket_name                 = "my-family-photos-2024"

  # Optional customization
  project_name    = "immich-family"
  server_location = "nbg1"
  domain_name     = "photos.example.com"  # Optional: enables HTTPS
  admin_email     = "admin@example.com"
}

output "immich_url" {
  value = module.immich.immich_url
}

output "admin_password" {
  value     = module.immich.admin_password
  sensitive = true
}
```

## Examples

- [Complete deployment](./examples/complete) - Full featured setup with new network
- [Existing network](./examples/existing-network) - Using existing Hetzner Cloud network infrastructure

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| hcloud | ~> 1.50 |
| random | ~> 3.1 |
| null | ~> 3.1 |

## Providers

| Name | Version |
|------|---------|
| hcloud | ~> 1.50 |
| random | ~> 3.1 |
| null | ~> 3.1 |

## Resources

| Name | Type |
|------|------|
| [hcloud_server.immich](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_volume.immich_data](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [hcloud_volume_attachment.immich_data](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume_attachment) | resource |
| [hcloud_network.immich_network](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network) | resource |
| [hcloud_network_subnet.immich_subnet](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/network_subnet) | resource |
| [hcloud_firewall.immich_firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_firewall_attachment.immich_firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall_attachment) | resource |
| [hcloud_ssh_key.immich_key](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/ssh_key) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [null_resource.immich_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| hcloud_token | Hetzner Cloud API token | `string` | n/a | yes |
| ssh_public_keys | List of SSH public keys for server access | `list(string)` | n/a | yes |
| backblaze_application_key_id | Backblaze B2 Application Key ID | `string` | n/a | yes |
| backblaze_application_key | Backblaze B2 Application Key (secret) | `string` | n/a | yes |
| backblaze_bucket_name | Backblaze B2 bucket name for media storage | `string` | n/a | yes |
| project_name | Name of the project (used for resource naming) | `string` | `"immich-family"` | no |
| server_location | Hetzner Cloud server location | `string` | `"nbg1"` | no |
| domain_name | Domain name for Immich (optional, leave empty for IP access) | `string` | `""` | no |
| admin_email | Admin email address for Immich | `string` | `"admin@localhost"` | no |
| allowed_ssh_ips | List of IP addresses/CIDR blocks allowed for SSH access | `list(string)` | `["0.0.0.0/0"]` | no |
| backblaze_region | Backblaze B2 region | `string` | `"us-west-000"` | no |

## Outputs

| Name | Description |
|------|-------------|
| immich_url | URL to access Immich |
| server_ip | Public IP address of the server |
| ssh_connection | SSH connection command |
| admin_credentials | Initial admin credentials |
| admin_password | Admin password for initial setup |
| cost_breakdown | Monthly cost breakdown in EUR |
| next_steps | What to do after deployment |
| management_commands | Useful management commands |

## 📱 Mobile App Setup

### iOS / Android
1. Download **Immich** from app store
2. Enter server URL from terraform output
3. Login with admin credentials from `terraform output -raw admin_password`
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

## 🛠️ Architecture

### Network Configuration Options

The module supports two network deployment modes:

#### 🆕 New Network (Default)
```hcl
# Creates new network infrastructure
# No additional configuration needed
```

#### 🔗 Existing Network Integration
```hcl
module "immich-hetzner" {
  source = "andreimerfu/hcloud-immich/hcloud"

  # Use existing network
  use_existing_network = true
  existing_network_id  = "12345"           # Your network ID
  existing_subnet_id   = "67890"           # Optional: specific subnet
  server_private_ip    = "10.0.1.100"      # Optional: specific IP

  # ... other configuration
}
```

**Benefits of Existing Network**:
- 🔗 Integration with existing infrastructure
- 🛡️ Shared security policies and firewall rules
- 💰 Cost savings (no additional network charges)
- 📊 Centralized network management

### Infrastructure Components
- **Hetzner Cloud Server**: CX22 (2 vCPU, 8GB RAM)
- **Volume**: 20GB for system, database, and cache
- **Network**: Private network with firewall protection (supports existing networks)
- **SSL**: Automatic Let's Encrypt certificates (with domain)

### Storage Strategy
- **Local Volume**: System files, database, JuiceFS cache
- **JuiceFS + Backblaze B2**: Unlimited photo storage as mounted filesystem
- **Cost Model**: Fixed server cost + variable B2 storage (€0.005/GB/month)

### Services
- **Immich**: Complete photo management with AI features
- **PostgreSQL**: Metadata and user data
- **Redis**: Caching and job queue
- **JuiceFS**: Filesystem layer for B2 object storage
- **Nginx**: Reverse proxy with SSL (when domain provided)

## 🔒 Security Features

- **Firewall protection** (Hetzner Cloud + UFW)
- **Fail2ban** brute-force protection
- **SSH key authentication** only
- **HTTPS with Let's Encrypt** (with domain)
- **Automatic security updates**

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please read the contribution guidelines and submit pull requests for any improvements.
