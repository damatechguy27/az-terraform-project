variable "name" {
  description = "Name of the subnet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the parent VNet."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the parent VNet."
  type        = string
}

variable "address_prefixes" {
  description = "List of CIDR blocks for the subnet. Must be inside the parent VNet's address space."
  type        = list(string)

  validation {
    condition     = length(var.address_prefixes) > 0 && alltrue([for c in var.address_prefixes : can(cidrnetmask(c))])
    error_message = "address_prefixes must be a non-empty list of valid CIDRs."
  }
}
