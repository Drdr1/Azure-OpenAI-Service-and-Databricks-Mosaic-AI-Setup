variable "openai_account_name" {
  description = "Name of the Azure OpenAI account"
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

variable "sku_name" {
  description = "SKU name of the Azure OpenAI account"
  type        = string
  default     = "S0"
}

variable "managed_identity_id" {
  description = "ID of the user assigned managed identity"
  type        = string
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the user assigned managed identity"
  type        = string
}

variable "network_default_action" {
  description = "Default action for network access control (Allow or Deny)"
  type        = string
  default     = "Deny"
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the OpenAI service"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of subnet IDs allowed to access the OpenAI service"
  type        = list(string)
  default     = []
}

variable "key_vault_key_id" {
  description = "ID of the Key Vault key for customer managed encryption"
  type        = string
  default     = null
}

variable "gpt35_deployment_name" {
  description = "Name of the GPT-3.5 Turbo deployment"
  type        = string
  default     = "gpt-35-turbo"
}

variable "gpt35_model_version" {
  description = "Version of the GPT-3.5 Turbo model"
  type        = string
  default     = "0125"
}

variable "gpt4_deployment_name" {
  description = "Name of the GPT-4 deployment"
  type        = string
  default     = "gpt-4"
}

variable "gpt4_model_version" {
  description = "Version of the GPT-4 model"
  type        = string
  default     = "0613"
}

variable "deployment_scale_type" {
  description = "Scale type for model deployments"
  type        = string
  default     = "Standard"
}

variable "gpt35_capacity" {
  description = "Capacity for GPT-3.5 Turbo deployment"
  type        = number
  default     = 1
}

variable "gpt4_capacity" {
  description = "Capacity for GPT-4 deployment"
  type        = number
  default     = 1
}

variable "create_databricks" {
  description = "Whether to create a Databricks workspace"
  type        = bool
  default     = true
}

variable "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
  default     = "openai-databricks"
}

variable "databricks_sku" {
  description = "SKU of the Databricks workspace"
  type        = string
  default     = "premium"
}

variable "databricks_public_access" {
  description = "Whether to enable public network access for Databricks"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "quota_alert_threshold" {
  description = "Threshold for quota alert"
  type        = number
  default     = 100
}

variable "action_group_id" {
  description = "ID of the action group for alerts"
  type        = string
}
