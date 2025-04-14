variable "name" {
  description = "The name of the container registry"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources should be created"
  type        = string
}

variable "identity_id" {
  description = "The ID of the managed identity"
  type        = string
}

variable "principal_id" {
  description = "The principal ID of the managed identity"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "create_role_assignments" {
  description = "Whether to create role assignments (requires elevated permissions)"
  type        = bool
  default     = false
}