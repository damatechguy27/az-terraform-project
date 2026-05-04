variable "name_prefix" {
  description = "Prefix for the storage account name. A 6-char random hex suffix is appended for global uniqueness; total must fit in 24 chars."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,18}$", var.name_prefix))
    error_message = "name_prefix must be 3-18 chars, lowercase letters and numbers only."
  }
}

variable "location" {
  description = "Azure region for the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the storage account."
  type        = string
}

variable "container_name" {
  description = "Name of the blob container to create inside the storage account."
  type        = string
  default     = "web"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,62}$", var.container_name))
    error_message = "container_name must be 3-63 chars, lowercase alphanumeric/hyphens, starting with a letter or number."
  }
}

variable "replication_type" {
  description = "Azure Storage replication tier. LRS = local, ZRS = zone-redundant, GRS = geo-redundant."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "replication_type must be one of LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "index_html_content" {
  description = "HTML content written to the index.html blob inside the container."
  type        = string
}

variable "tags" {
  description = "Tags applied to the storage account."
  type        = map(string)
  default     = {}
}
