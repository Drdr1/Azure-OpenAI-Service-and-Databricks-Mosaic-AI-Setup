provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
  }
  subscription_id = var.subscription_id
  use_oidc        = true
}

# Random string for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Data source for current client config
data "azurerm_client_config" "current" {}

# Resource Group
module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.environment == "prod" ? "openai-rg" : "${var.environment}-openai-rg"
  location = var.location
  tags     = var.tags
}

# Networking
module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = var.location
  environment         = var.environment
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = {
    openai     = ["10.0.1.0/24"]
    gateway    = ["10.0.2.0/24"]
    container  = ["10.0.3.0/24"]
  }
  allowed_ip_ranges   = var.allowed_ip_ranges
  tags                = var.tags
}

# Key Vault
module "key_vault" {
  source              = "./modules/key_vault"
  name                = "${var.environment}-openai-kv"
  resource_group_name = module.resource_group.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  allowed_ip_ranges   = var.allowed_ip_ranges
  subnet_ids          = [module.networking.subnet_ids["openai"]]
  tags                = var.tags
}

# Managed Identity
module "managed_identity" {
  source              = "./modules/managed_identity"
  name                = "${var.environment}-openai-identity"
  resource_group_name = module.resource_group.name
  location            = var.location
  key_vault_id        = module.key_vault.id
  tags                = var.tags
}

# OpenAI Service
module "openai" {
  source                = "./modules/openai"
  name                  = "${var.environment}-openai-service"
  resource_group_name   = module.resource_group.name
  location              = var.location
  identity_id           = module.managed_identity.id
  subnet_id             = module.networking.subnet_ids["openai"]
  allowed_ip_ranges     = var.allowed_ip_ranges
  key_vault_id          = module.key_vault.id
  gpt35_capacity        = var.gpt35_capacity
  gpt4_capacity         = var.gpt4_capacity
  tags                  = var.tags
  depends_on            = [module.key_vault]
}

# Databricks
module "databricks" {
  source                     = "./modules/databricks"
  name                       = "${var.environment}-mosaic-ai-workspace"
  resource_group_name        = module.resource_group.name
  location                   = var.location
  managed_resource_group_name = "${var.environment}-mosaic-ai-databricks-rg"
  tags                       = var.tags
}

# Container Registry
module "container_registry" {
  source              = "./modules/container_registry"
  name                = "${var.environment}kongacr"
  resource_group_name = module.resource_group.name
  location            = var.location
  identity_id         = module.managed_identity.id
  principal_id        = module.managed_identity.principal_id
  create_role_assignments = false  # Set to false if you don't have permissions
  tags                = var.tags
}

# Kong API Gateway
module "kong" {
  source              = "./modules/kong"
  name                = "${var.environment}-kong-api-gateway"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["container"]
  identity_id         = module.managed_identity.id
  acr_login_server    = module.container_registry.login_server
  acr_name            = module.container_registry.name
  acr_admin_username  = module.container_registry.admin_username
  acr_admin_password  = module.container_registry.admin_password
  tags                = var.tags  
  depends_on          = [module.container_registry]
}

# Application Gateway
module "app_gateway" {
  source              = "./modules/app_gateway"
  name                = "${var.environment}-openai-appgw"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["gateway"]
  identity_id         = module.managed_identity.id
  backend_ip_address  = module.kong.ip_address
  tags                = var.tags
  depends_on          = [module.kong]
}

# Monitoring
module "monitoring" {
  source                = "./modules/monitoring"
  resource_group_name   = module.resource_group.name
  location              = var.location
  environment           = var.environment
  alert_email           = var.alert_email
  appgw_id              = module.app_gateway.id
  openai_id             = module.openai.id
  quota_alert_threshold = var.quota_alert_threshold
  tags                  = var.tags
}

# Storage for Terraform state
module "storage" {
  source              = "./modules/storage"
  name                = "${var.environment}tfstate${random_string.suffix.result}"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

