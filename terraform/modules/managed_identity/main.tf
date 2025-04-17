resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Grant the managed identity access to Key Vault
resource "azurerm_key_vault_access_policy" "identity_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_user_assigned_identity.this.tenant_id
  object_id    = azurerm_user_assigned_identity.this.principal_id
  
  key_permissions = [
    "Get", "List"
  ]
  
  secret_permissions = [
    "Get", "List", "Set"
  ]
  
  certificate_permissions = [
    "Get", "List"
  ]
}