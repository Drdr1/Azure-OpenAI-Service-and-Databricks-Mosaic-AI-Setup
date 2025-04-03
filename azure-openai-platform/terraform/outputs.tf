output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "databricks_workspace_url" {
  value = azurerm_databricks_workspace.databricks.workspace_url
}

output "kong_fqdn" {
  value = azurerm_container_group.kong.fqdn
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}
