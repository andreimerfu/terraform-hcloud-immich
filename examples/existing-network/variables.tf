# ================================================================
# Required Variables
# ================================================================

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "List of SSH public keys for server access"
  type        = list(string)
}

variable "s3_access_key_id" {
  description = "S3-compatible storage Access Key ID (recommended: Backblaze B2)"
  type        = string
  sensitive   = true
}

variable "s3_secret_access_key" {
  description = "S3-compatible storage Secret Access Key (recommended: Backblaze B2)"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "S3-compatible storage bucket name for media storage"
  type        = string
}

# ================================================================
# Network Variables (Required for Existing Network)
# ================================================================

variable "existing_network_id" {
  description = "ID of existing Hetzner Cloud network"
  type        = string
}

variable "existing_subnet_id" {
  description = "ID of existing subnet within the network (optional)"
  type        = string
  default     = null
}

variable "server_private_ip" {
  description = "Private IP address to assign to the server (must be within subnet range)"
  type        = string
  default     = null
}

# ================================================================
# Optional Variables
# ================================================================

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "immich-family"
}

variable "server_location" {
  description = "Hetzner Cloud server location"
  type        = string
  default     = "nbg1"
}

variable "domain_name" {
  description = "Domain name for Immich (optional, leave empty for IP access)"
  type        = string
  default     = ""
}

variable "admin_email" {
  description = "Admin email address for Immich"
  type        = string
  default     = "admin@localhost"
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "s3_region" {
  description = "S3-compatible storage region (recommended: 'us-west-000' for Backblaze B2)"
  type        = string
  default     = "us-west-000"
}

variable "s3_endpoint" {
  description = "S3-compatible storage endpoint URL (leave empty for Backblaze B2 auto-detection)"
  type        = string
  default     = ""
}