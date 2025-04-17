output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.id
}

output "name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.name
}

output "public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_ip
}

output "fqdn" {
  description = "The FQDN of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_ip
}