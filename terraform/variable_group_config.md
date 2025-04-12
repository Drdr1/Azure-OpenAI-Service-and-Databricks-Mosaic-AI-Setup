# Azure DevOps Variable Group Configuration

This document provides instructions for setting up the Azure DevOps variable group that's linked to Azure Key Vault for secure credential management.

## Variable Group Configuration

1. In your Azure DevOps project, navigate to **Pipelines** > **Library** > **Variable groups**
2. Click **+ Variable group** to create a new variable group
3. Configure the variable group with the following settings:

```
Name: openai-variables
Description: Variables for OpenAI infrastructure deployment
Link secrets from an Azure key vault: Yes
Azure subscription: azure-oidc-connection
Key vault name: [Your Key Vault Name]
```

4. Select the following secrets to include in the variable group:

- `openai-api-key`
- `kong-admin-token`
- `log-analytics-key`
- `openai-quota-value`
- `ssl-cert-password` (if applicable)

5. Add the following pipeline variables (not from Key Vault):

```
Environment: production
KeyVaultName: [Your Key Vault Name]
OpenAIAccountName: [Your OpenAI Account Name]
```

6. Click **Save** to create the variable group

## Environment Configuration

Create environment-specific variable files in the following structure:

```
/environments/
  /production/
    terraform.tfvars
  /development/
    terraform.tfvars
  /staging/
    terraform.tfvars
```

Example content for `environments/production/terraform.tfvars`:

```hcl
prefix = "openai-prod"
location = "eastus"
tags = {
  Environment = "Production"
  ManagedBy = "Terraform"
  Project = "OpenAI"
}
allowed_ip_ranges = ["10.0.0.0/8", "172.16.0.0/12"]
```

## Pipeline Configuration

The pipelines are already configured to:
1. Use OIDC authentication with Azure
2. Reference variables from the variable group
3. Load environment-specific variables from the appropriate tfvars file
4. Store state in Azure Storage with proper backend configuration

No sensitive data is exposed in the pipeline configurations.
