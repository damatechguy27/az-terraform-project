variable "project" {
  description = "Short project name used as a naming prefix for all resources."
  type        = string
  default     = "tftest"

  validation {
    condition     = can(regex("^[a-z0-9]{1,16}$", var.project))
    error_message = "project must be 1-16 chars, lowercase alphanumeric only."
  }
}

variable "environment" {
  description = "Deployment environment. Used in resource names and tags."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "environment must be one of: dev, stg, prd."
  }
}

variable "cost_center" {
  description = "Cost center tag value for chargeback reporting."
  type        = string
  default     = "sandbox"
}

variable "env_config" {
  description = "Per-environment VM size, VNet CIDR, and Azure region. The active entry is selected by var.environment."
  type = map(object({
    vm_size  = string
    cidr     = string
    location = string
  }))
  default = {
    dev = {
      vm_size  = "Standard_B1ms" # small
      cidr     = "10.30.0.0/16"
      location = "eastus" # us-east
    }
    stg = {
      vm_size  = "Standard_B1s" # medium
      cidr     = "10.20.0.0/16"
      location = "westus" # us-west
    }
    prd = {
      vm_size  = "Standard_B2s" # large
      cidr     = "10.10.0.0/16"
      location = "centralus" # us-central
    }
  }

  validation {
    condition = alltrue([
      contains(keys(var.env_config), "dev"),
      contains(keys(var.env_config), "stg"),
      contains(keys(var.env_config), "prd"),
    ])
    error_message = "env_config must define entries for dev, stg, and prd."
  }

  validation {
    condition = alltrue([
      for env, cfg in var.env_config :
      can(regex("^Standard_", cfg.vm_size)) &&
      can(cidrnetmask(cfg.cidr)) &&
      length(cfg.location) > 0
    ])
    error_message = "Each env_config entry needs a Standard_* vm_size, a valid CIDR, and a non-empty location."
  }
}

variable "admin_username" {
  description = "Linux admin username for the VM."
  type        = string
  default     = "azureuser"

  validation {
    condition     = !contains(["root", "admin", "administrator"], lower(var.admin_username))
    error_message = "admin_username must not be root, admin, or administrator (Azure rejects these)."
  }
}

# variable "allowed_ssh_cidr" {
#   description = "CIDR allowed to reach the VM on port 22. Must be scoped — 0.0.0.0/0 is rejected."
#   type        = string

#   validation {
#     condition     = can(cidrnetmask(var.allowed_ssh_cidr)) && var.allowed_ssh_cidr != "0.0.0.0/0"
#     error_message = "allowed_ssh_cidr must be a valid CIDR and must not be 0.0.0.0/0. Use your /32 or a small office range."
#   }
# }

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 1024
    error_message = "os_disk_size_gb must be between 30 and 1024."
  }
}
