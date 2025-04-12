/**
 * Variables for the main Terraform configuration
 * This file defines all variables needed for the infrastructure deployment
 * with security best practices in mind.
 */

variable "prefix" {
  description = "Prefix to be used for all resource names"
  type        = string
  default     = "openai"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "openai-rg"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access secured resources"
  type        = list(string)
  default     = []
  sensitive   = true
}

# SSL Certificate variables
variable "ssl_cert_data" {
  description = "SSL certificate data in PFX format (base64 encoded)"
  type        = string
  default     = null
  sensitive   = true
}

variable "ssl_cert_password" {
  description = "Password for the SSL certificate"
  type        = string
  default     = null
  sensitive   = true
}

# Secrets for Key Vault
variable "openai_api_key" {
  description = "API key for OpenAI service"
  type        = string
  sensitive   = true
}

variable "kong_admin_token" {
  description = "Admin token for Kong API Gateway"
  type        = string
  sensitive   = true
}

variable "log_analytics_key" {
  description = "Primary or secondary key of the Log Analytics workspace"
  type        = string
  sensitive   = true
}

variable "alert_email_address" {
  description = "Email address for alerts"
  type        = string
  default     = "team@domain.com"
}
