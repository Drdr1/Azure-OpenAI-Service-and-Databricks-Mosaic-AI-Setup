output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.databricks.workspace_url
}
