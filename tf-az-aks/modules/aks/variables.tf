variable "name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the AKS cluster."
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster's API server FQDN. Lowercase alphanumeric + hyphens, must start with a letter."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}[a-z0-9]$", var.dns_prefix))
    error_message = "dns_prefix must be 2-54 chars, lowercase alphanumeric/hyphens, start with a letter, end alphanumeric."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster (e.g. 1.30). null = AKS default."
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 100
    error_message = "node_count must be between 1 and 100."
  }
}

variable "node_vm_size" {
  description = "VM SKU for the default node pool. AKS requires at least 2 vCPUs and 4 GB RAM."
  type        = string
  default     = "Standard_B2s"

  validation {
    condition     = can(regex("^Standard_", var.node_vm_size))
    error_message = "node_vm_size must be a Standard_* SKU."
  }
}

variable "tags" {
  description = "Tags applied to the cluster."
  type        = map(string)
  default     = {}
}
