output "id" {
  description = "Azure resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "Fully-qualified domain name of the cluster's API server."
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "host" {
  description = "Kubernetes API server URL. Used by helm/kubernetes providers."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Base64-encoded client certificate for cluster auth."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64-encoded client key for cluster auth."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded cluster CA certificate."
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "kube_config_raw" {
  description = "Full kubeconfig as a string. Save to a file to use with kubectl."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
