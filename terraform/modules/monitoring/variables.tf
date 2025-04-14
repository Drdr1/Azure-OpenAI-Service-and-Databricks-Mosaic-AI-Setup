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

variable "alert_email" {
  description = "Email address for alerts"
  type        = string
}

variable "appgw_id" {
  description = "The ID of the Application Gateway"
  type        = string
}

variable "openai_id" {
  description = "The ID of the OpenAI service"
  type        = string
}

variable "quota_alert_threshold" {
  description = "Threshold for OpenAI quota usage alert"
  type        = number
  default     = 80
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}