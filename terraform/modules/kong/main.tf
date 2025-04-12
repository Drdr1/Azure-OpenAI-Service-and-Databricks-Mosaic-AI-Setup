/**
 * Kong API Gateway Module
 * This module creates a Kong API Gateway using Azure Container Instances
 * with proper security configurations and managed identity.
 */

# Container Registry for Kong image
resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.container_registry_sku
  admin_enabled       = false # Disable admin credentials for security
  tags                = var.tags
}

# Assign the managed identity ACR Pull role
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.managed_identity_principal_id
}

# Network profile for Container Group
resource "azurerm_network_profile" "kong_network_profile" {
  count               = var.use_private_network ? 1 : 0
  name                = "${var.container_group_name}-network-profile"
  location            = var.location
  resource_group_name = var.resource_group_name

  container_network_interface {
    name = "kong-nic"

    ip_configuration {
      name      = "kong-ip-config"
      subnet_id = var.subnet_id
    }
  }
}

# Kong Container Group
resource "azurerm_container_group" "kong" {
  name                = var.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = var.use_private_network ? "Private" : "Public"
  dns_name_label      = var.use_private_network ? null : var.dns_name_label
  os_type             = "Linux"
  network_profile_id  = var.use_private_network ? azurerm_network_profile.kong_network_profile[0].id : null
  tags                = var.tags

  # Use managed identity instead of admin credentials
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  container {
    name   = "kong"
    image  = "${var.container_registry_name}.azurecr.io/${var.kong_image_name}:${var.kong_image_tag}"
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = 8000
      protocol = "TCP"
    }

    ports {
      port     = 8001
      protocol = "TCP"
    }

    ports {
      port     = 8443
      protocol = "TCP"
    }

    ports {
      port     = 8444
      protocol = "TCP"
    }

    environment_variables = {
      "KONG_DATABASE"      = "off"
      "KONG_PROXY_LISTEN"  = "0.0.0.0:8000, 0.0.0.0:8443 ssl"
      "KONG_ADMIN_LISTEN"  = "0.0.0.0:8001, 0.0.0.0:8444 ssl"
      "KONG_LOG_LEVEL"     = "notice"
      "KONG_PROXY_ACCESS_LOG" = "/dev/stdout"
      "KONG_ADMIN_ACCESS_LOG" = "/dev/stdout"
      "KONG_PROXY_ERROR_LOG"  = "/dev/stderr"
      "KONG_ADMIN_ERROR_LOG"  = "/dev/stderr"
    }

    # Add secure environment variables from Key Vault
    dynamic "secure_environment_variable" {
      for_each = var.secure_environment_variables
      content {
        name  = secure_environment_variable.key
        value = secure_environment_variable.value
      }
    }

    # Mount volume for Kong configuration
    volume {
      name       = "kong-config"
      mount_path = "/usr/local/kong/conf"
      
      secret = {
        secret = var.kong_config_base64
      }
    }
  }

  # Diagnostic settings
  diagnostics {
    log_analytics {
      log_type      = "ContainerInsights"
      workspace_id  = var.log_analytics_workspace_id
      workspace_key = var.log_analytics_workspace_key
    }
  }

  # Lifecycle to ignore changes to image tag for CI/CD updates
  lifecycle {
    ignore_changes = [
      container[0].image,
      tags
    ]
  }
}

# Create alert for Kong container health
resource "azurerm_monitor_metric_alert" "kong_health" {
  name                = "${var.container_group_name}-health-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_container_group.kong.id]
  description         = "Alert when Kong container is not running"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.ContainerInstance/containerGroups"
    metric_name      = "CpuUsage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 0.1
  }

  action {
    action_group_id = var.action_group_id
  }
}
