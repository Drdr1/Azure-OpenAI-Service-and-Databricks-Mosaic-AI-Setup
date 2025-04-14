resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "this" {
  name                = "openai-kv-${random_string.kv_suffix.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "standard"
  
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.subnet_ids
  }
  
  tags = var.tags
}

# Grant the current user/service principal access to Key Vault for initial setup
resource "azurerm_key_vault_access_policy" "terraform_policy" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id
  
  key_permissions = [
    "Get", "List", "Create", "Delete", "Update"
  ]
  
  secret_permissions = [
    "Get", "List", "Set", "Delete"
  ]
  
  certificate_permissions = [
    "Get", "List", "Create", "Delete"
  ]
}