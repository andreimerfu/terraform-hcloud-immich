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

# Deploy Immich with unlimited photo storage
module "immich" {
  source = "../../"

  # Required variables
  hcloud_token                    = var.hcloud_token
  ssh_public_keys                = var.ssh_public_keys
  s3_access_key_id               = var.s3_access_key_id
  s3_secret_access_key           = var.s3_secret_access_key
  s3_bucket_name                 = var.s3_bucket_name

  # Optional customization
  project_name      = var.project_name
  server_location   = var.server_location
  domain_name       = var.domain_name
  admin_email       = var.admin_email
  allowed_ssh_ips   = var.allowed_ssh_ips
  s3_region         = var.s3_region
  s3_endpoint       = var.s3_endpoint
}