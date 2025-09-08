# Immich with Existing Hetzner Network

This example demonstrates how to deploy Immich using existing Hetzner Cloud network infrastructure instead of creating new networking resources.

## Use Cases

- **Shared Infrastructure**: When you have other services in the same network
- **Centralized Management**: Using existing network policies and firewall rules
- **IP Address Management**: Maintaining consistent IP addressing schemes
- **Cost Optimization**: Reusing existing network resources

## Prerequisites

1. **Existing Hetzner Cloud Network**: Must be in same location as server
2. **Available IP Space**: Subnet must have available IP addresses
3. **Network Access**: Proper firewall rules for Immich ports
4. **Network Information**: Network and subnet IDs from Hetzner Console

## Required Network Ports

Ensure your existing network allows these ports:
- **22**: SSH access
- **80**: HTTP (for Let's Encrypt challenges)
- **443**: HTTPS (if using domain)
- **2283**: Immich application port

## Configuration

### Find Network Information

1. **Hetzner Cloud Console** → **Networks**
2. **Select your network** → Note the **Network ID**
3. **Click network details** → Note **Subnet IDs** and **IP ranges**
4. **Plan IP assignment** → Choose available IP for server

### Example Configuration

```hcl
module "immich-hetzner" {
  source = "andreimerfu/hcloud-immich/hcloud"
  
  # Standard configuration
  hcloud_token         = var.hcloud_token
  ssh_public_keys      = var.ssh_public_keys
  s3_access_key_id     = var.s3_access_key_id
  s3_secret_access_key = var.s3_secret_access_key
  s3_bucket_name       = var.s3_bucket_name
  
  # Existing network configuration
  use_existing_network = true
  existing_network_id  = "12345"           # Your network ID
  existing_subnet_id   = "67890"           # Optional: specific subnet
  server_private_ip    = "10.0.1.100"      # Optional: specific IP
  
  # Server and security configuration
  server_type          = "cx22"            # Adjust server size as needed
  allowed_ssh_ips      = ["203.0.113.0/24"] # Restrict to your network
  allowed_http_ips     = ["0.0.0.0/0", "::/0"] # Public access
  allowed_https_ips    = ["0.0.0.0/0", "::/0"] # Public access
  allowed_immich_ips   = ["10.0.0.0/8"]    # Private network only
  
  # Resource organization
  resource_labels = {
    environment = "production"
    team        = "infrastructure"
    component   = "immich"
    network     = "existing"
  }
}
```

### Configuration Options

#### Server Configuration
- `server_type`: Choose appropriate server size (cx11-cx52, cpx11-cpx51)
- `server_location`: Must match your existing network location

#### Security Configuration
- `allowed_ssh_ips`: Restrict SSH to specific networks/IPs
- `allowed_http_ips`: Control HTTP access (port 80)
- `allowed_https_ips`: Control HTTPS access (port 443) 
- `allowed_immich_ips`: Control Immich access (port 2283) - consider private network only

#### Network Integration
- `use_existing_network`: Set to `true`
- `existing_network_id`: Your network ID from Hetzner Console
- `existing_subnet_id`: Optional - specific subnet ID
- `server_private_ip`: Optional - specific IP within subnet range

## Deployment

```bash
# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit with your network IDs and credentials

# Deploy
terraform init
terraform plan
terraform apply

# Get connection info
terraform output network_info
terraform output immich_url
```

## Network Integration Benefits

- **🔗 Shared Resources**: Server integrates with existing infrastructure
- **🛡️ Consistent Security**: Inherits existing firewall and security policies  
- **📊 Centralized Monitoring**: Network traffic visible in existing monitoring
- **💰 Cost Efficient**: No additional network resource charges
- **🔧 Simplified Management**: One network to manage instead of multiple

## Troubleshooting

### Common Issues

1. **IP Conflicts**: Ensure chosen IP is not already in use
2. **Location Mismatch**: Network and server must be in same Hetzner location
3. **Subnet Capacity**: Verify subnet has available IP addresses
4. **Firewall Rules**: Check network firewall allows required ports

### Validation Commands

```bash
# Check network configuration
terraform output network_info

# Test connectivity
ssh root@$(terraform output -raw server_ip)
curl -I $(terraform output -raw immich_url)

# Check private network
ssh root@$(terraform output -raw server_ip) 'ip route'
```

## Migration from Standalone

If migrating from a standalone deployment to existing network:

1. **Export data** from current Immich instance
2. **Note network requirements** for new deployment  
3. **Deploy with existing network** configuration
4. **Import data** to new instance
5. **Update DNS/bookmarks** to new server IP

This maintains your photos while integrating with existing network infrastructure.