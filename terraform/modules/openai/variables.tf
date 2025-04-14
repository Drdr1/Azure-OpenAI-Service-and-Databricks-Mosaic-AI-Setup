variable "name" {
  description = "The name of the OpenAI service"
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

variable "subnet_id" {
  description = "The ID of the subnet for network rules"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the OpenAI service"
  type        = list(string)
  default     = []
}

variable "key_vault_id" {
  description = "The ID of the key vault to store secrets"
  type        = string
}

variable "gpt35_capacity" {
  description = "Capacity for GPT-3.5 Turbo model"
  type        = number
  default     = 10
}

variable "gpt4_capacity" {
  description = "Capacity for GPT-4 model"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}