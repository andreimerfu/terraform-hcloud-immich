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
  backblaze_application_key_id   = var.backblaze_application_key_id
  backblaze_application_key      = var.backblaze_application_key
  backblaze_bucket_name         = var.backblaze_bucket_name

  # Optional customization
  project_name      = var.project_name
  server_location   = var.server_location
  domain_name       = var.domain_name
  admin_email       = var.admin_email
  allowed_ssh_ips   = var.allowed_ssh_ips
  backblaze_region  = var.backblaze_region
}