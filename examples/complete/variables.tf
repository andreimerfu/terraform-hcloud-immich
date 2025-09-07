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

variable "backblaze_application_key_id" {
  description = "Backblaze B2 Application Key ID"
  type        = string
  sensitive   = true
}

variable "backblaze_application_key" {
  description = "Backblaze B2 Application Key (secret)"
  type        = string
  sensitive   = true
}

variable "backblaze_bucket_name" {
  description = "Backblaze B2 bucket name for media storage"
  type        = string
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

variable "backblaze_region" {
  description = "Backblaze B2 region"
  type        = string
  default     = "us-west-000"
}