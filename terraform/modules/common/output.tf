output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for name, subnet in azurerm_subnet.subnets : name => subnet.id }
}

output "log_analytics_id" {
  description = "ID of the created Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.log_analytics.id
}

output "log_analytics_workspace_id" {
  description = "Workspace ID of the created Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.log_analytics.workspace_id
}

output "managed_identity_id" {
  description = "ID of the created managed identity"
  value       = azurerm_user_assigned_identity.managed_identity.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the created managed identity"
  value       = azurerm_user_assigned_identity.managed_identity.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID of the created managed identity"
  value       = azurerm_user_assigned_identity.managed_identity.client_id
}

output "tenant_id" {
  description = "Tenant ID from the current client configuration"
  value       = data.azurerm_client_config.current.tenant_id
}

output "subscription_id" {
  description = "Subscription ID from the current client configuration"
  value       = data.azurerm_client_config.current.subscription_id
}
