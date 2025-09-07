# ================================================================
# Budget Family Setup - Variables
# ================================================================

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
  
  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "At least one SSH public key must be provided."
  }
}

variable "s3_access_key_id" {
  description = "S3-compatible storage Access Key ID (recommended: Backblaze B2 Application Key ID for cost-effectiveness)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.s3_access_key_id) > 0
    error_message = "S3 Access Key ID is required."
  }
}

variable "s3_secret_access_key" {
  description = "S3-compatible storage Secret Access Key (recommended: Backblaze B2 Application Key for cost-effectiveness)"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.s3_secret_access_key) > 0
    error_message = "S3 Secret Access Key is required."
  }
}

variable "s3_bucket_name" {
  description = "S3-compatible storage bucket name for media storage (recommended: Backblaze B2 private bucket)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.s3_bucket_name))
    error_message = "Bucket name must contain only lowercase letters, numbers, and hyphens."
  }
}

# ================================================================
# Optional Variables with Defaults
# ================================================================

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "immich-family"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "server_location" {
  description = "Hetzner Cloud server location"
  type        = string
  default     = "nbg1"
  
  validation {
    condition     = contains(["nbg1", "fsn1", "hel1", "ash", "hil"], var.server_location)
    error_message = "Server location must be one of: nbg1, fsn1, hel1, ash, hil."
  }
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
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.admin_email))
    error_message = "Admin email must be a valid email address."
  }
}

variable "allowed_ssh_ips" {
  description = "List of IP addresses/CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  
  validation {
    condition     = length(var.allowed_ssh_ips) > 0
    error_message = "At least one SSH IP address must be specified."
  }
}

variable "s3_region" {
  description = "S3-compatible storage region (recommended: 'us-west-000' for Backblaze B2 cost-effectiveness)"
  type        = string
  default     = "us-west-000"
  
  validation {
    condition     = length(var.s3_region) > 0
    error_message = "S3 region must be specified."
  }
}

variable "s3_endpoint" {
  description = "S3-compatible storage endpoint URL (recommended: leave empty for Backblaze B2 auto-detection, or specify custom S3 endpoint)"
  type        = string
  default     = ""
}