output "id" {
  description = "Azure resource ID of the VM."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "Name of the VM."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Primary private IP of the VM's NIC."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Public IP of the VM, or null if create_public_ip = false."
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}
