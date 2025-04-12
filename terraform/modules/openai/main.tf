/**
 * OpenAI Module
 * This module creates Azure OpenAI resources with proper security
 * configurations and managed identity integration.
 */

# Azure OpenAI Service
resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name
  tags                = var.tags

  # Use managed identity for authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  # Network access control
  network_acls {
    default_action = var.network_default_action
    ip_rules       = var.allowed_ip_ranges
    
  }

  # Customer managed key from Key Vault (if enabled)
  dynamic "customer_managed_key" {
    for_each = var.key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id = var.key_vault_key_id
      identity_client_id = var.managed_identity_id
    }
  }
}

# GPT-35-Turbo Deployment
resource "azurerm_cognitive_deployment" "gpt35_turbo" {
  name                 = var.gpt35_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = var.gpt35_model_version
  }

  sku {
    name     = var.deployment_scale_type
    capacity = var.gpt35_capacity
  }
}

# GPT-4 Deployment
resource "azurerm_cognitive_deployment" "gpt4" {
  name                 = var.gpt4_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = var.gpt4_model_version
  }

  sku {
    name    = var.deployment_scale_type
    capacity = var.gpt4_capacity
  }
}

# Databricks Workspace (if enabled)
resource "azurerm_databricks_workspace" "databricks" {
  count               = var.create_databricks ? 1 : 0
  name                = var.databricks_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.databricks_sku
  tags                = var.tags

  # Use managed identity
  managed_resource_group_name = "${var.resource_group_name}-databricks-managed"

  # Network security
  public_network_access_enabled = var.databricks_public_access
  
  # Customer managed key from Key Vault (if enabled)
  dynamic "customer_managed_key" {
    for_each = var.key_vault_key_id != null && var.create_databricks ? [1] : []
    content {
      key_vault_key_id = var.key_vault_key_id
      managed_identity_id = var.managed_identity_id
    }
  }
}

# Diagnostic settings for OpenAI
resource "azurerm_monitor_diagnostic_setting" "openai_diag" {
  name                       = "${var.openai_account_name}-diagnostics"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Audit"

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  enabled_log {
    category = "RequestResponse"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}

# Quota Alert
resource "azurerm_monitor_metric_alert" "quota_alert" {
  name                = "${var.openai_account_name}-quota-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_cognitive_account.openai.id]
  description         = "Alert on high request count"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "TotalCalls"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.quota_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }
}

# Role assignment for managed identity to access OpenAI
resource "azurerm_role_assignment" "openai_contributor" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = var.managed_identity_principal_id
}
