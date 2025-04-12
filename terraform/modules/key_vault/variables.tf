variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
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

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the Key Vault"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "managed_identities" {
  description = "List of managed identities that need access to the Key Vault"
  type = list(object({
    name                    = string
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "ssl_cert_name" {
  description = "Name of the SSL certificate to store in Key Vault"
  type        = string
  default     = "app-gateway-cert"
}

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

variable "secrets" {
  description = "Map of secrets to store in Key Vault"
  type        = map(string)
  default     = {}
  sensitive   = true
}
