variable "name" {
  description = "Name of the NSG."
  type        = string
}

variable "location" {
  description = "Azure region for the NSG."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the NSG."
  type        = string
}

variable "security_rules" {
  description = "Map of NSG rules keyed by rule name."
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for r in var.security_rules :
      contains(["Inbound", "Outbound"], r.direction) &&
      contains(["Allow", "Deny"], r.access) &&
      contains(["Tcp", "Udp", "Icmp", "*"], r.protocol) &&
      r.priority >= 100 && r.priority <= 4096
    ])
    error_message = "Each rule needs direction in {Inbound,Outbound}, access in {Allow,Deny}, protocol in {Tcp,Udp,Icmp,*}, and priority in [100,4096]."
  }
}

variable "tags" {
  description = "Tags applied to the NSG."
  type        = map(string)
  default     = {}
}
