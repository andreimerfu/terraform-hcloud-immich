output "immich_url" {
  description = "URL to access Immich"
  value       = module.immich.immich_url
}

output "server_ip" {
  description = "Public IP address of the server"
  value       = module.immich.server_ip
}

output "server_private_ip" {
  description = "Private IP address of the server"
  value       = module.immich.network_info.server_private_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = module.immich.ssh_connection
}

output "network_info" {
  description = "Network configuration information"
  value       = module.immich.network_info
}

output "admin_credentials" {
  description = "Initial admin credentials"
  value       = module.immich.admin_credentials
  sensitive   = true
}

output "admin_password" {
  description = "Admin password (use: terraform output -raw admin_password)"
  value       = module.immich.admin_password
  sensitive   = true
}