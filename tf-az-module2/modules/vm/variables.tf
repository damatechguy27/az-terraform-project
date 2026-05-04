variable "name" {
  description = "Name of the VM. Used as prefix for the NIC and (optional) public IP."
  type        = string
}

variable "location" {
  description = "Azure region for the VM and its NIC/public IP."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the VM."
  type        = string
}

variable "subnet_id" {
  description = "Azure resource ID of the subnet the NIC attaches to."
  type        = string
}

variable "vm_size" {
  description = "Azure VM SKU."
  type        = string
  default     = "Standard_B1s"

  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "vm_size must be a Standard_* SKU."
  }
}

variable "admin_username" {
  description = "Linux admin username."
  type        = string
  default     = "azureuser"

  validation {
    condition     = !contains(["root", "admin", "administrator"], lower(var.admin_username))
    error_message = "admin_username must not be root, admin, or administrator."
  }
}

variable "admin_ssh_public_key" {
  description = "OpenSSH public key for VM login. Password auth is disabled in this module."
  type        = string

  validation {
    condition     = can(regex("^(ssh-rsa |ssh-ed25519 |ecdsa-sha2-)", var.admin_ssh_public_key))
    error_message = "admin_ssh_public_key must be an OpenSSH public key (ssh-rsa, ssh-ed25519, or ecdsa-sha2-*)."
  }
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 1024
    error_message = "os_disk_size_gb must be between 30 and 1024."
  }
}

variable "os_disk_storage_account_type" {
  description = "OS disk SKU. Standard_LRS is cheapest; use Premium_LRS / Premium_ZRS in prod."
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "Premium_ZRS", "StandardSSD_ZRS"], var.os_disk_storage_account_type)
    error_message = "os_disk_storage_account_type must be a supported managed disk SKU."
  }
}

variable "image" {
  description = "Source image reference."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "create_public_ip" {
  description = "Whether to attach a Standard-SKU public IP to the VM's NIC."
  type        = bool
  default     = true
}

variable "custom_data" {
  description = "Optional cloud-init or shell script (base64-encoded) injected at first boot. Treat as sensitive — anything passed here is visible to the VM and stored in state."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to the VM, NIC, and (if created) public IP."
  type        = map(string)
  default     = {}
}
