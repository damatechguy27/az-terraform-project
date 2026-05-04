output "id" {
  description = "Azure resource ID of the NSG."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "Name of the NSG."
  value       = azurerm_network_security_group.this.name
}
