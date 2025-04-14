variable "name" {
  description = "The name of the Kong API Gateway"
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

variable "subnet_id" {
  description = "The ID of the subnet for the container group"
  type        = string
}

variable "identity_id" {
  description = "The ID of the managed identity"
  type        = string
}

variable "acr_login_server" {
  description = "The login server URL of the container registry"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}


variable "acr_admin_username" {
  description = "The admin username of the container registry"
  type        = string
}

variable "acr_admin_password" {
  description = "The admin password of the container registry"
  type        = string
  sensitive   = true
}
variable "acr_name" {
  description = "The name of the Azure Container Registry"
  type        = string
}
