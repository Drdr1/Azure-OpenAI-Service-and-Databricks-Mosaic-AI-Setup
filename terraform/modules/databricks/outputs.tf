output "id" {
  description = "The ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.id
}

output "name" {
  description = "The name of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.name
}

output "workspace_url" {
  description = "The workspace URL of the Databricks workspace"
  value       = azurerm_databricks_workspace.this.workspace_url
}