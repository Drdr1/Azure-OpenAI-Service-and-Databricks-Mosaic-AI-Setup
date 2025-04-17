output "log_analytics_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "app_insights_id" {
  description = "The ID of the Application Insights"
  value       = azurerm_application_insights.this.id
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "The connection string of the Application Insights"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}