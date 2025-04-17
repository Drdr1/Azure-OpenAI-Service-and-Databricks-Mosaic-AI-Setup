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
  default     = ["156.202.52.186"]  # Add your current IP address here
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

# New variables for AKS
variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

# New variables for Kong Helm
variable "kong_replica_count" {
  description = "Number of Kong replicas"
  type        = number
  default     = 2
}
