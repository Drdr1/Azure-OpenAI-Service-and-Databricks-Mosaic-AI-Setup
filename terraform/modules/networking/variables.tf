variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where resources should be created"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, dev, test)"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "Map of subnet names to address prefixes"
  type        = map(list(string))
  default     = {
    openai     = ["10.0.1.0/24"]
    gateway    = ["10.0.2.0/24"]
    container  = ["10.0.3.0/24"]
  }
}

variable "service_endpoints" {
  description = "Map of subnet names to service endpoints"
  type        = map(list(string))
  default     = {
    openai     = ["Microsoft.CognitiveServices", "Microsoft.KeyVault"]
    container  = ["Microsoft.ContainerRegistry"]
    gateway    = []
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}