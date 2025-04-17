variable "name" {
  description = "The name of the Kong deployment"
  type        = string
  default     = "kong"
}

variable "namespace" {
  description = "The Kubernetes namespace to deploy Kong into"
  type        = string
  default     = "kong"
}

variable "chart_version" {
  description = "The version of the Kong Helm chart to deploy"
  type        = string
  default     = "2.19.0"
}

variable "replica_count" {
  description = "The number of Kong replicas to deploy"
  type        = number
  default     = 2
}

variable "image_repository" {
  description = "Kong Docker image repository"
  type        = string
  default     = "kong"
}

variable "image_tag" {
  description = "Kong Docker image tag"
  type        = string
  default     = "3.2"
}

variable "service_type" {
  description = "The type of Kubernetes service to create for Kong"
  type        = string
  default     = "LoadBalancer"
}

variable "internal_lb" {
  description = "Whether to use an internal load balancer"
  type        = bool
  default     = true
}

variable "use_acr_credentials" {
  description = "Whether to use ACR credentials for pulling Kong images"
  type        = bool
  default     = false
}

variable "acr_login_server" {
  description = "The login server for ACR"
  type        = string
  default     = ""
}

variable "cpu_request" {
  description = "CPU request for Kong pods"
  type        = string
  default     = "200m"
}

variable "memory_request" {
  description = "Memory request for Kong pods"
  type        = string
  default     = "256Mi"
}

variable "cpu_limit" {
  description = "CPU limit for Kong pods"
  type        = string
  default     = "500m"
}

variable "memory_limit" {
  description = "Memory limit for Kong pods"
  type        = string
  default     = "512Mi"
}

variable "helm_timeout" {
  description = "Timeout for Helm operations in seconds"
  type        = number
  default     = 900  # 15 minutes
}

variable "aks_dependency" {
  description = "Dependency on AKS cluster to ensure proper ordering"
  type        = any
  default     = null
}
variable "fetch_kubernetes_resources" {
  description = "Whether to fetch Kubernetes resources (set to false if you have connection issues)"
  type        = bool
  default     = false
}