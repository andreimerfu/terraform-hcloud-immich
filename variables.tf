# ================================================================
# Budget Family Setup - Variables
# ================================================================

# ================================================================
# Required Variables
# ================================================================


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

# ================================================================
# Network Configuration Variables
# ================================================================

variable "use_existing_network" {
  description = "Whether to use an existing Hetzner Cloud network instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_network_id" {
  description = "ID of existing Hetzner Cloud network to use (required if use_existing_network is true)"
  type        = string
  default     = null

  validation {
    condition     = var.existing_network_id == null || (var.existing_network_id != null && var.existing_network_id != "")
    error_message = "The existing_network_id must be a non-empty string when provided."
  }
}

variable "existing_subnet_id" {
  description = "ID of existing subnet within the network (optional - will use first subnet if not specified)"
  type        = string
  default     = null
}



variable "server_private_ip" {
  description = "Private IP address to assign to the server (optional - will use automatic assignment if not specified)"
  type        = string
  default     = null

  validation {
    condition     = var.server_private_ip == null || can(cidrhost("0.0.0.0/0", 0))
    error_message = "The server_private_ip must be a valid IP address."
  }
}

variable "create_new_network_config" {
  description = "Configuration for new network creation (when use_existing_network is false)"
  type = object({
    network_ip_range = string
    subnet_ip_range  = string
    network_zone     = string
  })
  default = {
    network_ip_range = "10.0.0.0/16"
    subnet_ip_range  = "10.0.1.0/24"
    network_zone     = "eu-central"
  }

  validation {
    condition     = can(cidrhost(var.create_new_network_config.network_ip_range, 0)) && can(cidrhost(var.create_new_network_config.subnet_ip_range, 0))
    error_message = "Network and subnet IP ranges must be valid CIDR blocks."
  }
}

# ================================================================
# Server Configuration Variables
# ================================================================

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cx22"

  validation {
    condition     = contains(["cx11", "cx21", "cx22", "cx31", "cx32", "cx41", "cx42", "cx51", "cx52", "cpx11", "cpx21", "cpx31", "cpx41", "cpx51"], var.server_type)
    error_message = "Server type must be a valid Hetzner Cloud server type."
  }
}

# ================================================================
# Firewall Configuration Variables
# ================================================================

variable "allowed_http_ips" {
  description = "List of IP addresses/CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]

  validation {
    condition     = length(var.allowed_http_ips) > 0
    error_message = "At least one HTTP IP address must be specified."
  }
}

variable "allowed_https_ips" {
  description = "List of IP addresses/CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]

  validation {
    condition     = length(var.allowed_https_ips) > 0
    error_message = "At least one HTTPS IP address must be specified."
  }
}

variable "allowed_immich_ips" {
  description = "List of IP addresses/CIDR blocks allowed for direct Immich port (2283) access"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]

  validation {
    condition     = length(var.allowed_immich_ips) > 0
    error_message = "At least one Immich IP address must be specified."
  }
}

# ================================================================
# Resource Labels Configuration
# ================================================================

variable "resource_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default = {
    environment = "production"
    managed_by  = "terraform"
    component   = "immich"
  }

  validation {
    condition     = length(var.resource_labels) >= 0
    error_message = "Resource labels must be a valid map of string key-value pairs."
  }
}
