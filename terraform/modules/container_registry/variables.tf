variable "name" {
  description = "Name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure location"
  type        = string
}

variable "sku" {
  description = "SKU of the container registry"
  type        = string
  default     = "Premium"
}

variable "identity_id" {
  description = "User assigned identity ID"
  type        = string
}

variable "principal_id" {
  description = "Principal ID to assign roles to"
  type        = string
}

variable "create_role_assignments" {
  description = "Create role assignments for ACR"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}