/**
 * Main Terraform Configuration
 * This file integrates all modules with Azure Key Vault for centralized secret management
 * and implements security best practices including managed identities and OIDC authentication.
 */

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  backend "azurerm" {
    # Backend configuration will be provided via pipeline variables
    # No sensitive data is hardcoded here
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
  }
  # Use OIDC authentication from pipeline
  # No subscription_id hardcoded here
}

# Common resources including resource group, networking, and managed identity
module "common" {
  source = "./modules/common"
  
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  
  vnet_name           = "${var.prefix}-vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "app-gateway-subnet"
      address_prefixes = ["10.0.1.0/24"]
    },
    {
      name             = "api-subnet"
      address_prefixes = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    }
  ]
  
  log_analytics_name  = "${var.prefix}-log-analytics"
  managed_identity_name = "${var.prefix}-managed-identity"
}

# Key Vault for centralized secret management
module "key_vault" {
  source = "./modules/key_vault"
  
  key_vault_name      = "${var.prefix}-key-vault"
  location            = var.location
  resource_group_name = module.common.resource_group_name
  tags                = var.tags
  
  # Network security
  allowed_subnet_ids  = [for name, id in module.common.subnet_ids : id]
  allowed_ip_ranges   = var.allowed_ip_ranges
  
  # Managed identity access
  managed_identities = [
    {
      name                    = "terraform-identity"
      object_id               = module.common.managed_identity_principal_id
      secret_permissions      = ["Get", "List"]
      key_permissions         = ["Get", "List"]
      certificate_permissions = ["Get", "List"]
    }
  ]
  
  # Store SSL certificate if provided
  ssl_cert_name      = "app-gateway-cert"
  ssl_cert_data      = var.ssl_cert_data
  ssl_cert_password  = var.ssl_cert_password
  
  # Store secrets
  secrets = {
    "openai-api-key"         = var.openai_api_key
    "kong-admin-token"       = var.kong_admin_token
    "log-analytics-key"      = var.log_analytics_key
  }
  
  depends_on = [module.common]
}

# OpenAI service with managed identity
module "openai" {
  source = "./modules/openai"
  
  openai_account_name  = "${var.prefix}-openai"
  location             = var.location
  resource_group_name  = module.common.resource_group_name
  tags                 = var.tags
  
  # Managed identity
  managed_identity_id          = module.common.managed_identity_id
  managed_identity_principal_id = module.common.managed_identity_principal_id
  
  # Network security
  network_default_action = "Deny"
  allowed_subnet_ids     = [for name, id in module.common.subnet_ids : id]
  allowed_ip_ranges      = var.allowed_ip_ranges
  
  # Model deployments
  gpt35_deployment_name = "gpt-35-turbo-0125"
  gpt35_model_version   = "0125"
  gpt4_deployment_name  = "gpt-4-0613"
  gpt4_model_version    = "0613"
  
  # Monitoring
  log_analytics_workspace_id = module.common.log_analytics_id
  action_group_id            = azurerm_monitor_action_group.notify_team.id
  
  depends_on = [module.common, module.key_vault]
}

# Kong API Gateway with managed identity
module "kong" {
  source = "./modules/kong"
  
  container_registry_name = "${var.prefix}kongacr"
  container_group_name    = "${var.prefix}-kong-api-gateway"
  location                = var.location
  resource_group_name     = module.common.resource_group_name
  tags                    = var.tags
  
  # Managed identity
  managed_identity_id          = module.common.managed_identity_id
  managed_identity_principal_id = module.common.managed_identity_principal_id
  
  # Network configuration
  use_private_network = true
  subnet_id           = module.common.subnet_ids["api-subnet"]
  
  # Secure environment variables from Key Vault
  secure_environment_variables = {
    "KONG_ADMIN_TOKEN" = "@Microsoft.KeyVault(SecretUri=${module.key_vault.key_vault_uri}secrets/kong-admin-token/)"
  }
  
  # Monitoring
  log_analytics_workspace_id  = module.common.log_analytics_id
  log_analytics_workspace_key = "@Microsoft.KeyVault(SecretUri=${module.key_vault.key_vault_uri}secrets/log-analytics-key/)"
  action_group_id             = azurerm_monitor_action_group.notify_team.id
  
  depends_on = [module.common, module.key_vault]
}

# Application Gateway with WAF and managed identity
module "app_gateway" {
  source = "./modules/app_gateway"
  
  app_gateway_name    = "${var.prefix}-app-gateway"
  location            = var.location
  resource_group_name = module.common.resource_group_name
  tags                = var.tags
  
  # Managed identity
  managed_identity_id = module.common.managed_identity_id
  
  # Network configuration
  subnet_id           = module.common.subnet_ids["app-gateway-subnet"]
  
  # SSL certificate from Key Vault
  ssl_certificate_name     = "app-gateway-cert"
  ssl_certificate_secret_id = module.key_vault.ssl_certificate_secret_id
  
  # Backend configuration
  backend_address_pools = [
    {
      name  = "kong-pool"
      fqdns = [module.kong.container_group_fqdn]
    }
  ]
  
  backend_http_settings = [
    {
      name                  = "http-settings"
      cookie_based_affinity = "Disabled"
      port                  = module.kong.kong_proxy_port
      protocol              = "Http"
      request_timeout       = 20
    }
  ]
  
  http_listeners = [
    {
      name = "https-listener"
    }
  ]
  
  routing_rules = [
    {
      name                       = "rule1"
      rule_type                  = "Basic"
      http_listener_name         = "https-listener"
      backend_address_pool_name  = "kong-pool"
      backend_http_settings_name = "http-settings"
    }
  ]
  
  # WAF configuration
  waf_enabled        = true
  waf_firewall_mode  = "Prevention"
  
  # Monitoring
  log_analytics_workspace_id = module.common.log_analytics_id
  
  depends_on = [module.common, module.key_vault, module.kong]
}

# Action group for alerts
resource "azurerm_monitor_action_group" "notify_team" {
  name                = "${var.prefix}-notify-team"
  resource_group_name = module.common.resource_group_name
  short_name          = "notifyteam"

  email_receiver {
    name          = "team-email"
    email_address = var.alert_email_address
  }
}

# Output important information
output "openai_endpoint" {
  value = module.openai.openai_endpoint
  description = "Endpoint URL of the Azure OpenAI service"
}

output "app_gateway_public_ip" {
  value = module.app_gateway.public_ip_address
  description = "Public IP address of the Application Gateway"
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
  description = "URI of the Key Vault"
}
