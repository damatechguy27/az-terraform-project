variable "name" {
  description = "Name of the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region for the VNet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the VNet."
  type        = string
}

variable "address_space" {
  description = "List of CIDR blocks for the VNet."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for c in var.address_space : can(cidrnetmask(c))])
    error_message = "address_space must be a non-empty list of valid CIDRs."
  }
}

variable "tags" {
  description = "Tags applied to the VNet."
  type        = map(string)
  default     = {}
}
