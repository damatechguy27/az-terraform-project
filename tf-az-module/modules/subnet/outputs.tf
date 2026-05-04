output "id" {
  description = "Azure resource ID of the subnet."
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "Name of the subnet."
  value       = azurerm_subnet.this.name
}

output "address_prefixes" {
  description = "CIDR blocks assigned to the subnet."
  value       = azurerm_subnet.this.address_prefixes
}
