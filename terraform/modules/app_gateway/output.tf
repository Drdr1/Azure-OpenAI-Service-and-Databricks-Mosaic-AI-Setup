output "app_gateway_id" {
  description = "ID of the created Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "app_gateway_name" {
  description = "Name of the created Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "app_gateway_frontend_ip_configuration" {
  description = "Frontend IP configuration of the Application Gateway"
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration
}

output "public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN of the public IP address"
  value       = azurerm_public_ip.appgw_pip.fqdn
}

output "backend_address_pools" {
  description = "Backend address pools of the Application Gateway"
  value       = azurerm_application_gateway.appgw.backend_address_pool
}
