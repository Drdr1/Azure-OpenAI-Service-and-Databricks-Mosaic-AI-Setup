provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
  use_oidc        = true
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = module.aks.host
  client_certificate     = module.aks.client_certificate
  client_key             = module.aks.client_key
  cluster_ca_certificate = module.aks.cluster_ca_certificate
}

# Helm provider for Kubernetes deployments
provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_certificate     = module.aks.client_certificate
    client_key             = module.aks.client_key
    cluster_ca_certificate = module.aks.cluster_ca_certificate
  }
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
    kubernetes = ["10.0.3.0/24"]  # Renamed from container to kubernetes
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
  skip_key_vault_secret = true  # Skip Key Vault secret access temporarily
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

# AKS Cluster - NEW
module "aks" {
  source              = "./modules/aks"
  name                = "${var.environment}-kong-aks"
  resource_group_name = module.resource_group.name
  location            = var.location
  dns_prefix          = "${var.environment}-kong-aks"
  kubernetes_version  = "1.30.6"
  subnet_id           = module.networking.subnet_ids["kubernetes"]
  identity_id         = module.managed_identity.id
  acr_id              = module.container_registry.id
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
  tags                = var.tags
  create_acr_role_assignment = false
  depends_on          = [module.container_registry]
}

# Kong API Gateway deployed via Helm - NEW
module "kong_helm" {
  source              = "./modules/kong-helm"
  name                = "${var.environment}-kong"
  namespace           = "kong"
  replica_count       = var.kong_replica_count
  service_type        = "LoadBalancer"
  internal_lb         = true  # Use internal load balancer
  use_acr_credentials = false  # Set to false initially to use public images
  acr_login_server    = module.container_registry.login_server
  chart_version       = "2.35.1"  # Specify a stable version
  image_tag           = "3.5.0"
  
  # Pass the AKS module as a dependency
  aks_dependency      = module.aks
  
  # Make sure this module depends on the AKS module
  depends_on          = [module.aks]
}

# Application Gateway
module "app_gateway" {
  source              = "./modules/app-gateway"
  name                = "${var.environment}-openai-appgw"
  resource_group_name = module.resource_group.name
  location            = var.location
  subnet_id           = module.networking.subnet_ids["gateway"]
  identity_id         = module.managed_identity.id
  
  # Use the Kong service FQDN
  #backend_fqdn        = "${module.kong_helm.kong_service_name}.${module.kong_helm.kong_namespace}.svc.cluster.local"
  backend_ip_addresses = ["156.202.30.154"]
  tags                = var.tags
  depends_on          = [module.kong_helm]
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
