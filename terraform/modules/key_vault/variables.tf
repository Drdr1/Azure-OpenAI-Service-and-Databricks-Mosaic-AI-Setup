variable "name" {
  description = "The name of the key vault"
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

variable "tenant_id" {
  description = "The Azure AD tenant ID"
  type        = string
}

variable "object_id" {
  description = "The object ID of the current user/service principal"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the key vault"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet IDs allowed to access the key vault"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}