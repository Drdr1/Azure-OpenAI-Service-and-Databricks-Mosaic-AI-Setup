output "container_registry_id" {
  description = "ID of the created Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "container_registry_login_server" {
  description = "Login server URL of the Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "container_group_id" {
  description = "ID of the created Kong Container Group"
  value       = azurerm_container_group.kong.id
}

output "container_group_name" {
  description = "Name of the created Kong Container Group"
  value       = azurerm_container_group.kong.name
}

output "container_group_ip_address" {
  description = "IP address of the Kong Container Group"
  value       = azurerm_container_group.kong.ip_address
}

output "container_group_fqdn" {
  description = "FQDN of the Kong Container Group (if public)"
  value       = var.use_private_network ? null : azurerm_container_group.kong.fqdn
}

output "kong_proxy_port" {
  description = "HTTP port for Kong proxy"
  value       = 8000
}

output "kong_proxy_ssl_port" {
  description = "HTTPS port for Kong proxy"
  value       = 8443
}

output "kong_admin_port" {
  description = "HTTP port for Kong admin API"
  value       = 8001
}

output "kong_admin_ssl_port" {
  description = "HTTPS port for Kong admin API"
  value       = 8444
}
