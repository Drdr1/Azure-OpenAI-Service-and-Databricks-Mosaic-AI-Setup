# Production-Grade Infrastructure Documentation

## Overview

This documentation provides comprehensive information about the production-grade infrastructure implementation for the OpenAI platform. The infrastructure is deployed using Terraform with a modular approach, following security best practices including Azure Key Vault integration, managed identities, and OIDC authentication.

## Architecture

The infrastructure consists of the following components:

1. **Application Gateway** - WAF-enabled gateway that provides secure access to the API
2. **Kong API Gateway** - API management layer that routes requests to OpenAI services
3. **Azure OpenAI Service** - Cognitive services for AI capabilities
4. **Azure Key Vault** - Centralized secret management
5. **Azure Databricks** - Optional analytics workspace for AI development
6. **Networking** - Virtual network with proper subnet segmentation
7. **Monitoring** - Log Analytics workspace and diagnostic settings

## Module Structure

The infrastructure is organized into the following modules:

```
/
├── modules/
│   ├── app_gateway/      # Application Gateway with WAF
│   ├── common/           # Shared resources (RG, VNet, etc.)
│   ├── key_vault/        # Azure Key Vault for secrets
│   ├── kong/             # Kong API Gateway
│   └── openai/           # Azure OpenAI Service
├── environments/         # Environment-specific configurations
│   ├── production/
│   ├── development/
│   └── staging/
├── main.tf               # Main Terraform configuration
├── variables.tf          # Input variables
├── outputs.tf            # Output values
└── oidc.tf               # OIDC authentication configuration
```

## Security Implementations

### Azure Key Vault Integration

All sensitive data is stored in Azure Key Vault, including:
- API keys
- SSL certificates
- Admin tokens
- Monitoring credentials

Resources reference Key Vault secrets using Key Vault references, ensuring no sensitive data is exposed in the code or configuration files.

### Managed Identities

User-assigned managed identities are used for authentication between services:
- Application Gateway uses managed identity to access Key Vault for SSL certificates
- Kong API Gateway uses managed identity for ACR authentication
- OpenAI Service uses managed identity for secure access

### OIDC Authentication

OIDC tokens are used for authentication in CI/CD pipelines:
- Azure AD application with federated credentials for GitHub Actions and Azure DevOps
- Pipeline configurations use OIDC-based service connections
- No service principal credentials are stored in the code or pipeline

### Network Security

- Network ACLs restrict access to Key Vault
- Application Gateway provides WAF protection
- Private networking is used where possible
- Service endpoints secure communication between services

## Pipeline Configuration

The CI/CD pipelines are configured to use:
- OIDC authentication with Azure
- Variable groups linked to Key Vault
- Environment-specific variable files
- Secure handling of credentials

## Usage Instructions

### Prerequisites

1. Azure subscription
2. Azure DevOps project or GitHub repository
3. Terraform CLI (latest version)
4. Azure CLI (latest version)

### Deployment Steps

1. **Set up Azure DevOps Variable Group**
   - Follow instructions in `variable_group_config.md`

2. **Configure Environment Variables**
   - Create environment-specific `.tfvars` files in the `environments` directory

3. **Initialize Terraform**
   ```bash
   terraform init -backend-config=environments/[env]/backend.conf
   ```

4. **Plan Deployment**
   ```bash
   terraform plan -var-file=environments/[env]/terraform.tfvars
   ```

5. **Apply Deployment**
   ```bash
   terraform apply -var-file=environments/[env]/terraform.tfvars
   ```

### CI/CD Pipeline Setup

1. Create an OIDC-based service connection in Azure DevOps
2. Configure the variable group as described in `variable_group_config.md`
3. Create the pipeline using one of the provided YAML files
4. Run the pipeline to deploy the infrastructure

## Maintenance and Operations

### Updating Infrastructure

To update the infrastructure:
1. Modify the Terraform code as needed
2. Commit changes to the repository
3. The CI/CD pipeline will automatically deploy the changes

### Rotating Secrets

To rotate secrets:
1. Update the secrets in Azure Key Vault
2. No changes to the code or pipeline are required

### Monitoring

The infrastructure includes:
- Diagnostic settings for all resources
- Log Analytics workspace for centralized logging
- Alerts for quota and health monitoring

## Security Recommendations

For further security enhancements, consider:
1. Implementing Private Link for Azure services
2. Enabling Azure Defender for additional security monitoring
3. Implementing Just-In-Time access for administrative operations
4. Integrating security scanning tools in the CI/CD pipeline
5. Implementing automated key rotation policies

