/**
 * OIDC Authentication Configuration
 * This file configures OIDC authentication for Azure resources
 * to eliminate the need for long-lived credentials.
 */

# Create Azure AD application for OIDC authentication
resource "azuread_application" "oidc_app" {
  display_name = "${var.prefix}-oidc-app"
  
  # Configure web authentication
  web {
    redirect_uris = ["https://app.terraform.io/auth/oidc/callback"]
    
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
}

# Create service principal for the application
resource "azuread_service_principal" "oidc_sp" {
  client_id = azuread_application.oidc_app.application_id

}



# Create federated identity credential for GitHub Actions
resource "azuread_application_federated_identity_credential" "github_federated_credential" {
  application_id = azuread_application.oidc_app
  display_name          = "github-federated-credential"
  description           = "GitHub Actions federated credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_org}/${var.github_repo}:environment:${var.github_environment}"
}

# Create federated identity credential for Azure DevOps
resource "azuread_application_federated_identity_credential" "azdo_federated_credential" {
  application_id = azuread_application.oidc_app
  display_name          = "azdo-federated-credential"
  description           = "Azure DevOps federated credential"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://vstoken.dev.azure.com/${var.azure_devops_org}"
  subject               = "sc://${var.azure_devops_org}/${var.azure_devops_project}/${var.azure_devops_service_connection}"
}

# Assign Contributor role to the service principal at subscription level
resource "azurerm_role_assignment" "oidc_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.oidc_sp.object_id
}

# Assign Key Vault Administrator role to the service principal
resource "azurerm_role_assignment" "oidc_key_vault_admin" {
  scope                = module.key_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.oidc_sp.object_id
}

# Get current subscription details
data "azurerm_subscription" "current" {}

# Output OIDC configuration details
output "oidc_client_id" {
  description = "Client ID for OIDC authentication"
  value       = azuread_application.oidc_app.application_id
}

output "oidc_tenant_id" {
  description = "Tenant ID for OIDC authentication"
  value       = data.azurerm_client_config.current.tenant_id
}

output "oidc_subscription_id" {
  description = "Subscription ID for OIDC authentication"
  value       = data.azurerm_subscription.current.subscription_id
}
