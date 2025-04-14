output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.this.name
}

output "public_ip" {
  description = "The public IP address of the Application Gateway"
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "The FQDN of the Application Gateway"
  value       = azurerm_public_ip.this.fqdn
}