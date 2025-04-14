# Outputs
output "openai_endpoint" {
  value     = module.openai.endpoint
  sensitive = false
}

output "openai_service_name" {
  value = module.openai.name
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "databricks_workspace_url" {
  value = module.databricks.workspace_url
}

output "acr_name" {
  value = module.container_registry.name
}

output "kong_fqdn" {
  value = module.kong.ip_address
}

output "appgw_public_ip" {
  value = module.app_gateway.public_ip
}

output "tfstate_storage_account" {
  value = module.storage.name
}
