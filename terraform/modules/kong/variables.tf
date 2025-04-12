variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "container_registry_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Basic"
}

variable "managed_identity_id" {
  description = "ID of the user assigned managed identity"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the user assigned managed identity"
  type        = string
}

variable "container_group_name" {
  description = "Name of the Kong Container Group"
  type        = string
  default     = "kong-api-gateway"
}

variable "use_private_network" {
  description = "Whether to use private network for the container group"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "ID of the subnet for the container group when using private network"
  type        = string
  default     = null
}

variable "dns_name_label" {
  description = "DNS name label for the container group when using public IP"
  type        = string
  default     = "kong-api"
}

variable "kong_image_name" {
  description = "Name of the Kong Docker image"
  type        = string
  default     = "kong"
}

variable "kong_image_tag" {
  description = "Tag of the Kong Docker image"
  type        = string
  default     = "3.6"
}

variable "container_cpu" {
  description = "CPU cores allocated to the container"
  type        = string
  default     = "1.0"
}

variable "container_memory" {
  description = "Memory allocated to the container in GB"
  type        = string
  default     = "1.5"
}

variable "secure_environment_variables" {
  description = "Secure environment variables for the Kong container"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "kong_config_base64" {
  description = "Base64 encoded Kong configuration files"
  type        = string
  default     = null
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics"
  type        = string
}

variable "log_analytics_workspace_key" {
  description = "Primary or secondary key of the Log Analytics workspace"
  type        = string
  sensitive   = true
}

variable "action_group_id" {
  description = "ID of the action group for alerts"
  type        = string
}
