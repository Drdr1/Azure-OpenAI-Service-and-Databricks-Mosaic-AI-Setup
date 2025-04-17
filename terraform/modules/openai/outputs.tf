output "id" {
  description = "The ID of the OpenAI service"
  value       = azurerm_cognitive_account.openai.id
}

output "name" {
  description = "The name of the OpenAI service"
  value       = azurerm_cognitive_account.openai.name
}

output "endpoint" {
  description = "The endpoint of the OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "primary_key" {
  description = "The primary key of the OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "gpt35_deployment_id" {
  description = "The ID of the GPT-3.5 Turbo deployment"
  value       = azurerm_cognitive_deployment.gpt35.id
}

output "gpt4_deployment_id" {
  description = "The ID of the GPT-4 deployment"
  value       = azurerm_cognitive_deployment.gpt4.id
}