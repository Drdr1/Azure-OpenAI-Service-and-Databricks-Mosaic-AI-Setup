variable "name" {
  description = "The name of the Application Gateway"
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
  description = "The ID of the subnet for the Application Gateway"
  type        = string
}

variable "identity_id" {
  description = "The ID of the managed identity"
  type        = string
}

variable "backend_ip_address" {
  description = "The IP address of the backend service"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}