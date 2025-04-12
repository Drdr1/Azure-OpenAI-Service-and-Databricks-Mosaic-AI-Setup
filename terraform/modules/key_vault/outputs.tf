output "key_vault_id" {
  description = "ID of the created Key Vault"
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_uri" {
  description = "URI of the created Key Vault"
  value       = azurerm_key_vault.key_vault.vault_uri
}

output "ssl_certificate_id" {
  description = "ID of the SSL certificate in Key Vault"
  value       = var.ssl_cert_data != null ? azurerm_key_vault_certificate.ssl_cert[0].id : null
}

output "ssl_certificate_secret_id" {
  description = "Secret ID of the SSL certificate in Key Vault"
  value       = var.ssl_cert_data != null ? azurerm_key_vault_certificate.ssl_cert[0].secret_id : null
}

output "key_vault_name" {
  description = "Name of the created Key Vault"
  value       = azurerm_key_vault.key_vault.name
}
