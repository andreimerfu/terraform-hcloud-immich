output "immich_url" {
  description = "URL to access Immich"
  value       = module.immich.immich_url
}

output "server_ip" {
  description = "Public IP address of the server"
  value       = module.immich.server_ip
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = module.immich.ssh_connection
}

output "admin_credentials" {
  description = "Initial admin credentials"
  value       = module.immich.admin_credentials
  sensitive   = true
}

output "cost_breakdown" {
  description = "Monthly cost breakdown in EUR"
  value       = module.immich.cost_breakdown
}

output "next_steps" {
  description = "What to do after deployment"
  value       = module.immich.next_steps
}

output "management_commands" {
  description = "Useful management commands"
  value       = module.immich.management_commands
}

output "admin_password" {
  description = "Admin password (use: terraform output -raw admin_password)"
  value       = module.immich.admin_password
  sensitive   = true
}