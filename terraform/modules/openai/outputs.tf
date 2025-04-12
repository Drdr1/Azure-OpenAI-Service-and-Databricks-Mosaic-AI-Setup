output "openai_account_id" {
  description = "ID of the created Azure OpenAI account"
  value       = azurerm_cognitive_account.openai.id
}

output "openai_account_name" {
  description = "Name of the created Azure OpenAI account"
  value       = azurerm_cognitive_account.openai.name
}

output "openai_endpoint" {
  description = "Endpoint URL of the Azure OpenAI account"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "gpt35_deployment_id" {
  description = "ID of the GPT-3.5 Turbo deployment"
  value       = azurerm_cognitive_deployment.gpt35_turbo.id
}

output "gpt35_deployment_name" {
  description = "Name of the GPT-3.5 Turbo deployment"
  value       = azurerm_cognitive_deployment.gpt35_turbo.name
}

output "gpt4_deployment_id" {
  description = "ID of the GPT-4 deployment"
  value       = azurerm_cognitive_deployment.gpt4.id
}

output "gpt4_deployment_name" {
  description = "Name of the GPT-4 deployment"
  value       = azurerm_cognitive_deployment.gpt4.name
}

output "databricks_workspace_id" {
  description = "ID of the created Databricks workspace"
  value       = var.create_databricks ? azurerm_databricks_workspace.databricks[0].id : null
}

output "databricks_workspace_url" {
  description = "URL of the created Databricks workspace"
  value       = var.create_databricks ? azurerm_databricks_workspace.databricks[0].workspace_url : null
}

output "openai_principal_id" {
  description = "Principal ID of the OpenAI service"
  value       = azurerm_cognitive_account.openai.identity[0].principal_id
}
