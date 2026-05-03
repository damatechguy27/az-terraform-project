output "resource_group_name" {
  description = "Name of the resource group containing the sandbox VM."
  value       = azurerm_resource_group.main.name
}

output "vm_id" {
  description = "Azure resource ID of the Linux VM."
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_public_ip" {
  description = "Public IP address assigned to the VM."
  value       = azurerm_public_ip.main.ip_address
}

output "private_key_path" {
  description = "Path to the generated private key file (mode 0600). Treat as a secret."
  value       = local_file.terraprivkey.filename
}

output "ssh_command" {
  description = "Ready-to-run SSH command for connecting to the VM with the generated key."
  value       = "ssh -i ${local_file.terraprivkey.filename} ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}
