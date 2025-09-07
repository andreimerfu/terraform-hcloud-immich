# ================================================================
# Budget Family Setup - Outputs
# ================================================================

output "immich_url" {
  description = "URL to access Immich"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "http://${hcloud_server.immich.ipv4_address}:2283"
}

output "server_ip" {
  description = "Public IP address of the server"
  value       = hcloud_server.immich.ipv4_address
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh root@${hcloud_server.immich.ipv4_address}"
}

output "admin_credentials" {
  description = "Initial admin credentials"
  value = {
    email    = var.admin_email
    password = random_password.admin_password.result
  }
  sensitive = true
}

output "cost_breakdown" {
  description = "Monthly cost breakdown in EUR"
  value = {
    server_cx21       = "€5.83"
    volume_50gb       = "€2.40" 
    backblaze_500gb   = "~€2.50"
    total_estimated   = "~€10.73"
    note              = "Storage scales with usage (€0.005/GB/month)"
  }
}

output "next_steps" {
  description = "What to do after deployment"
  value = [
    "1. Wait ~10-15 minutes for setup to complete",
    "2. Access Immich at: ${var.domain_name != "" ? "https://${var.domain_name}" : "http://${hcloud_server.immich.ipv4_address}:2283"}",
    "3. Login with email: ${var.admin_email}",
    "4. Use the admin password from 'terraform output -raw admin_password'",
    "5. Configure mobile apps with the server URL",
    "6. Start uploading your photos!"
  ]
}

output "management_commands" {
  description = "Useful management commands"
  value = {
    check_status     = "ssh root@${hcloud_server.immich.ipv4_address} 'systemctl status immich'"
    view_logs        = "ssh root@${hcloud_server.immich.ipv4_address} 'journalctl -u immich -f'"
    restart_immich   = "ssh root@${hcloud_server.immich.ipv4_address} 'systemctl restart immich'"
    check_storage    = "ssh root@${hcloud_server.immich.ipv4_address} 'df -h /mnt/immich'"
    juicefs_status   = "ssh root@${hcloud_server.immich.ipv4_address} 'systemctl status juicefs'"
  }
}

output "admin_password" {
  description = "Admin password (use: terraform output -raw admin_password)"
  value       = random_password.admin_password.result
  sensitive   = true
}