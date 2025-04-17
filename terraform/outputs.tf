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

output "acr_login_server" {
  value = module.container_registry.login_server
}

# AKS outputs
output "aks_name" {
  value = module.aks.name
}

output "aks_host" {
  value     = module.aks.host
  sensitive = true
}

output "kube_config" {
  value     = module.aks.kube_config
  sensitive = true
}

output "aks_node_resource_group" {
  value = module.aks.node_resource_group
}

# Kong outputs
output "kong_namespace" {
  value = module.kong_helm.kong_namespace
}

output "kong_service_name" {
  value = module.kong_helm.kong_service_name
}

output "kong_status" {
  value = module.kong_helm.kong_status
}

# App Gateway outputs
output "appgw_public_ip" {
  value = module.app_gateway.public_ip
}

output "tfstate_storage_account" {
  value = module.storage.name
}