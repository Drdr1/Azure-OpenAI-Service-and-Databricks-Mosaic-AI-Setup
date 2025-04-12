variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "your-org"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "your-repo"
}

variable "github_environment" {
  description = "GitHub environment name"
  type        = string
  default     = "production"
}

variable "azure_devops_org" {
  description = "Azure DevOps organization name"
  type        = string
  default     = "your-azdo-org"
}

variable "azure_devops_project" {
  description = "Azure DevOps project name"
  type        = string
  default     = "your-azdo-project"
}

variable "azure_devops_service_connection" {
  description = "Azure DevOps service connection name"
  type        = string
  default     = "azure-oidc-connection"
}
