variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "environment" {
  description = "Environment name (prod, dev, test)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Project     = "OpenAI Platform"
    ManagedBy   = "Terraform"
  }
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
  default     = []
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

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
  default     = "platform-team@example.com"
}

variable "quota_alert_threshold" {
  description = "Threshold percentage for OpenAI quota usage alert"
  type        = number
  default     = 80
}