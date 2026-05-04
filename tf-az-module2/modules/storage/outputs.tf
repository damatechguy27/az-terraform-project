output "storage_account_id" {
  description = "Azure resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the storage account (prefix + random hex suffix)."
  value       = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "Primary access key for the storage account. Used by blobfuse to authenticate."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "container_name" {
  description = "Name of the blob container."
  value       = azurerm_storage_container.this.name
}

output "index_blob_url" {
  description = "URL of the index.html blob (private — auth required to read directly)."
  value       = azurerm_storage_blob.index.url
}
