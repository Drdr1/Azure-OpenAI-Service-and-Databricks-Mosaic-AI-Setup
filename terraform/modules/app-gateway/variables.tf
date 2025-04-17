variable "name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Application Gateway should be created"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the Application Gateway should be deployed"
  type        = string
}

variable "identity_id" {
  description = "The ID of the user-assigned identity for the Application Gateway"
  type        = string
}

variable "backend_ip_addresses" {
  description = "List of backend IP addresses"
  type        = list(string)
  default     = ["128.203.125.112"]  # Kong service IP
}

variable "backend_fqdns" {
  description = "List of backend FQDNs"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Tags to apply to the Application Gateway"
  type        = map(string)
  default     = {}
}
