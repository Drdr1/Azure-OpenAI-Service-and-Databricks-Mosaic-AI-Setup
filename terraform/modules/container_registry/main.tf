resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }
  
  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count               = var.create_role_assignments ? 1 : 0
  scope               = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id        = var.principal_id
}

resource "azurerm_role_assignment" "acr_push" {
  count               = var.create_role_assignments ? 1 : 0
  scope               = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id        = var.principal_id
}
# Role assignment for managed identity to ACR
# resource "azurerm_role_assignment" "acr_pull" {
#   scope                = azurerm_container_registry.this.id
#   role_definition_name = "AcrPull"
#   principal_id         = var.principal_id
# }

# resource "azurerm_role_assignment" "acr_push" {
#   scope                = azurerm_container_registry.this.id
#   role_definition_name = "AcrPush"
#   principal_id         = var.principal_id
