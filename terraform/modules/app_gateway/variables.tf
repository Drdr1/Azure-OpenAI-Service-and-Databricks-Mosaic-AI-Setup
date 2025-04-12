variable "app_gateway_name" {
  description = "Name of the Application Gateway"
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

variable "public_ip_name" {
  description = "Name of the public IP for the Application Gateway"
  type        = string
  default     = "appgw-pip"
}

variable "sku_name" {
  description = "SKU name of the Application Gateway"
  type        = string
  default     = "WAF_v2"
}

variable "sku_tier" {
  description = "SKU tier of the Application Gateway"
  type        = string
  default     = "WAF_v2"
}

variable "capacity" {
  description = "Capacity (instance count) of the Application Gateway"
  type        = number
  default     = 2
}

variable "managed_identity_id" {
  description = "ID of the user assigned managed identity"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the Application Gateway"
  type        = string
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = "app-gateway-cert"
}

variable "ssl_certificate_secret_id" {
  description = "Key Vault Secret ID of the SSL certificate"
  type        = string
}

variable "backend_address_pools" {
  description = "Backend address pools configuration"
  type = list(object({
    name        = string
    fqdns       = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "Backend HTTP settings configuration"
  type = list(object({
    name                  = string
    cookie_based_affinity = string
    port                  = number
    protocol              = string
    request_timeout       = number
    host_name             = optional(string)
    probe_name            = optional(string)
  }))
}

variable "http_listeners" {
  description = "HTTP listeners configuration"
  type = list(object({
    name      = string
    host_name = optional(string)
  }))
}

variable "routing_rules" {
  description = "Request routing rules configuration"
  type = list(object({
    name                       = string
    rule_type                  = string
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
    url_path_map_name          = optional(string)
  }))
}

variable "waf_enabled" {
  description = "Whether WAF is enabled"
  type        = bool
  default     = true
}

variable "waf_firewall_mode" {
  description = "WAF firewall mode (Detection or Prevention)"
  type        = string
  default     = "Prevention"
}

variable "waf_rule_set_type" {
  description = "WAF rule set type"
  type        = string
  default     = "OWASP"
}

variable "waf_rule_set_version" {
  description = "WAF rule set version"
  type        = string
  default     = "3.2"
}

variable "waf_file_upload_limit_mb" {
  description = "WAF file upload limit in MB"
  type        = number
  default     = 100
}

variable "waf_max_request_body_size_kb" {
  description = "WAF maximum request body size in KB"
  type        = number
  default     = 128
}

variable "health_probes" {
  description = "Health probes configuration"
  type = list(object({
    name                = string
    host                = optional(string)
    interval            = number
    path                = string
    protocol            = string
    timeout             = number
    unhealthy_threshold = number
    match_status_codes  = list(string)
  }))
  default = []
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
