terraform {
  required_version = ">= 1.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.50"
    }
  }
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Deploy Immich using existing network infrastructure
module "immich" {
  source = "../../"

  # Required variables
  ssh_public_keys      = var.ssh_public_keys
  s3_access_key_id     = var.s3_access_key_id
  s3_secret_access_key = var.s3_secret_access_key
  s3_bucket_name       = var.s3_bucket_name

  # Network configuration - use existing network
  use_existing_network = true
  existing_network_id  = var.existing_network_id
  existing_subnet_id   = var.existing_subnet_id
  server_private_ip    = var.server_private_ip

  # Optional customization
  project_name    = var.project_name
  server_location = var.server_location
  domain_name     = var.domain_name
  admin_email     = var.admin_email
  allowed_ssh_ips = var.allowed_ssh_ips
  s3_region       = var.s3_region
  s3_endpoint     = var.s3_endpoint
}