# ================================================================
# Immich Budget Family Setup - Single Module
# ================================================================
#
# Ultra cost-effective Immich deployment for families
# Estimated cost: €8-12/month with unlimited photo storage
#
# Components:
# - CX21 server (€5.83/month) - 2 vCPU, 8GB RAM
# - 50GB volume (€2.40/month) - System + database + cache
# - Backblaze B2 (€2.50/month) - 500GB photo storage via JuiceFS
# - Total: ~€10.73/month
# ================================================================

# ================================================================
# Data Sources
# ================================================================

# No provider configuration in modules - handled by root module

# Validate existing network when specified
data "hcloud_network" "existing" {
  count = var.use_existing_network ? 1 : 0
  id    = var.existing_network_id
}




# Locals for network configuration
locals {
  # Determine which network to use
  network_id = var.use_existing_network ? var.existing_network_id : hcloud_network.immich_network[0].id


  # Determine server IP configuration
  server_ip = var.server_private_ip != null ? var.server_private_ip : (
    var.use_existing_network ? "10.0.1.10" : "10.0.1.10"
  )
}

# ================================================================
# Random password for initial admin user
# ================================================================

resource "random_password" "admin_password" {
  length  = 16
  special = true
}

# ================================================================
# SSH Key
# ================================================================

resource "hcloud_ssh_key" "immich_key" {
  count      = length(var.ssh_public_keys)
  name       = "${var.project_name}-key-${count.index}"
  public_key = var.ssh_public_keys[count.index]
}

# ================================================================
# Network (Conditional Creation)
# ================================================================

# Create new network only if not using existing network
resource "hcloud_network" "immich_network" {
  count = var.use_existing_network ? 0 : 1

  name     = "${var.project_name}-network"
  ip_range = var.create_new_network_config.network_ip_range

  labels = merge(var.resource_labels, {
    project = var.project_name
    purpose = "immich-network"
  })
}

# Create new subnet only if not using existing network
resource "hcloud_network_subnet" "immich_subnet" {
  count = var.use_existing_network ? 0 : 1

  network_id   = hcloud_network.immich_network[0].id
  type         = "cloud"
  network_zone = var.create_new_network_config.network_zone
  ip_range     = var.create_new_network_config.subnet_ip_range
}

# ================================================================
# Storage Volume
# ================================================================

resource "hcloud_volume" "immich_data" {
  name     = "${var.project_name}-data"
  size     = 20 # 20GB for system + database + JuiceFS cache (photos in B2)
  location = var.server_location
  format   = "ext4"

  labels = merge(var.resource_labels, {
    project = var.project_name
    purpose = "immich-data"
  })
}

# ================================================================
# Server
# ================================================================

resource "hcloud_server" "immich" {
  name        = "${var.project_name}-server"
  image       = "ubuntu-22.04"
  server_type = var.server_type # Configurable server type with cx22 default
  location    = var.server_location
  ssh_keys    = hcloud_ssh_key.immich_key[*].id

  network {
    network_id = local.network_id
    ip         = local.server_ip
  }

  labels = merge(var.resource_labels, {
    project = var.project_name
    purpose = "immich-server"
  })

  # Basic setup script
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
  }))
}

# ================================================================
# Volume Attachment
# ================================================================

resource "hcloud_volume_attachment" "immich_data" {
  volume_id = hcloud_volume.immich_data.id
  server_id = hcloud_server.immich.id
  automount = false # We'll mount manually for better control
}

# ================================================================
# Firewall
# ================================================================

resource "hcloud_firewall" "immich_firewall" {
  name = "${var.project_name}-firewall"

  # SSH access
  rule {
    direction  = "in"
    port       = "22"
    protocol   = "tcp"
    source_ips = var.allowed_ssh_ips
  }

  # HTTP
  rule {
    direction  = "in"
    port       = "80"
    protocol   = "tcp"
    source_ips = var.allowed_http_ips
  }

  # HTTPS
  rule {
    direction  = "in"
    port       = "443"
    protocol   = "tcp"
    source_ips = var.allowed_https_ips
  }

  # Immich port
  rule {
    direction  = "in"
    port       = "2283"
    protocol   = "tcp"
    source_ips = var.allowed_immich_ips
  }
}

resource "hcloud_firewall_attachment" "immich_firewall" {
  firewall_id = hcloud_firewall.immich_firewall.id
  server_ids  = [hcloud_server.immich.id]
}

# ================================================================
# Setup Script
# ================================================================

resource "null_resource" "immich_setup" {
  depends_on = [
    hcloud_server.immich,
    hcloud_volume_attachment.immich_data
  ]

  triggers = {
    server_id = hcloud_server.immich.id
    volume_id = hcloud_volume.immich_data.id
  }

  connection {
    type = "ssh"
    host = hcloud_server.immich.ipv4_address
    user = "root"
  }

  # Copy setup script (without template processing)
  provisioner "file" {
    source      = "${path.module}/setup.sh"
    destination = "/tmp/setup.sh"
  }

  # Create environment file
  provisioner "file" {
    content     = <<-EOT
      #!/bin/bash
      export PROJECT_NAME='${var.project_name}'
      export DOMAIN_NAME='${var.domain_name}'
      export S3_ACCESS_KEY_ID='${var.s3_access_key_id}'
      export S3_SECRET_ACCESS_KEY='${var.s3_secret_access_key}'
      export S3_BUCKET_NAME='${var.s3_bucket_name}'
      export S3_REGION='${var.s3_region}'
      export S3_ENDPOINT='${var.s3_endpoint}'
      export ADMIN_EMAIL='${var.admin_email}'
      export ADMIN_PASSWORD='${random_password.admin_password.result}'
      export VOLUME_DEVICE='${hcloud_volume.immich_data.linux_device}'
      export ENABLE_HTTPS='${var.domain_name != "" ? "true" : "false"}'
    EOT
    destination = "/tmp/setup-env.sh"
  }

  # Run setup
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "chmod +x /tmp/setup-env.sh",
      ". /tmp/setup-env.sh && /tmp/setup.sh"
    ]
  }
}
