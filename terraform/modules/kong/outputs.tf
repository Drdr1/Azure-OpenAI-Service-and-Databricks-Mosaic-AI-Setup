output "id" {
  description = "The ID of the container group"
  value       = azurerm_container_group.kong.id
}

output "ip_address" {
  description = "The IP address of the Kong API Gateway"
  value       = azurerm_container_group.kong.ip_address
}

output "fqdn" {
  description = "The FQDN of the Kong API Gateway"
  value       = azurerm_container_group.kong.fqdn
}
# output "name" {
#   description = "The name of the container registry"
#   value       = azurerm_container_registry.this.name
# }

# output "admin_username" {
#   description = "The admin username of the container registry"
#   value       = azurerm_container_registry.this.admin_username
# }

# output "admin_password" {
#   description = "The admin password of the container registry"
#   value       = azurerm_container_registry.this.admin_password
#   sensitive   = true
# }