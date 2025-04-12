/**
 * Key Vault Module
 * This module creates an Azure Key Vault for centralized secret management
 * with proper access policies and network security.
 */

resource "azurerm_key_vault" "key_vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# Create access policy for the current deployment identity
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Purge", "Recover"
  ]

  certificate_permissions = [
    "Get", "List", "Create", "Import", "Update", "Delete"
  ]

  key_permissions = [
    "Get", "List", "Create", "Update", "Delete"
  ]
}

# Create access policies for managed identities
resource "azurerm_key_vault_access_policy" "managed_identities" {
  for_each     = { for identity in var.managed_identities : identity.name => identity }
  
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.value.object_id

  secret_permissions = each.value.secret_permissions
  key_permissions    = each.value.key_permissions
  certificate_permissions = each.value.certificate_permissions
}

# Store SSL certificate in Key Vault
resource "azurerm_key_vault_certificate" "ssl_cert" {
  count        = var.ssl_cert_data != null ? 1 : 0
  name         = var.ssl_cert_name
  key_vault_id = azurerm_key_vault.key_vault.id

  certificate {
    contents = var.ssl_cert_data
    password = var.ssl_cert_password
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

# Store secrets in Key Vault
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.key_vault.id
  
  depends_on = [azurerm_key_vault_access_policy.deployer]
}

# Get current client configuration
data "azurerm_client_config" "current" {}
