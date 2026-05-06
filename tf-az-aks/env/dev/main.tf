locals {
  environment = "dev"
  project     = "tfaks"

  config = {
    node_count   = 1
    node_vm_size = "Standard_B2s" # 2 vCPU, 4 GB — AKS minimum
    location     = "eastus"
  }

  name_prefix = "${local.project}-${local.environment}"

  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "terraform"
    CostCenter  = "sandbox"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${local.name_prefix}-rg"
  location = local.config.location
  tags     = local.common_tags
}

module "aks" {
  source = "../../modules/aks"

  name                = "${local.name_prefix}-cluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${local.project}${local.environment}"
  node_count          = local.config.node_count
  node_vm_size        = local.config.node_vm_size
  tags                = local.common_tags
}

resource "helm_release" "nginx" {
  name      = "nginx"
  chart     = "oci://registry-1.docker.io/bitnamicharts/nginx"
  namespace = "default"

  # Pin a known version in real use:
  # version = "18.3.6"

  values = [
    yamlencode({
      service = {
        type = "LoadBalancer"
      }
    })
  ]

  wait    = true
  timeout = 600 # LoadBalancer provisioning can take a couple of minutes
}

output "resource_group_name" {
  description = "Resource group containing the AKS cluster."
  value       = azurerm_resource_group.main.name
}

output "cluster_name" {
  description = "Name of the AKS cluster."
  value       = module.aks.name
}

output "get_credentials_command" {
  description = "Run this to point kubectl at the new cluster."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.name} --overwrite-existing"
}

output "get_nginx_ip_command" {
  description = "Run this after apply to fetch the nginx LoadBalancer's external IP."
  value       = "kubectl get svc -n ${helm_release.nginx.namespace} ${helm_release.nginx.name} -o jsonpath='{.status.loadBalancer.ingress[0].ip}'"
}
