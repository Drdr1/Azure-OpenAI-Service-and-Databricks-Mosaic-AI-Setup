/**
 * Application Gateway Module
 * This module creates an Azure Application Gateway with WAF protection
 * and proper security configurations.
 */

# Public IP for App Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Application Gateway with WAF
resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.capacity
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  gateway_ip_configuration {
    name      = "${var.app_gateway_name}-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  # Use Key Vault reference for SSL certificate
  ssl_certificate {
    name                = var.ssl_certificate_name
    key_vault_secret_id = var.ssl_certificate_secret_id
  }

  # Backend pools
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name  = backend_address_pool.value.name
      fqdns = lookup(backend_address_pool.value, "fqdns", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  # Backend HTTP settings
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      request_timeout       = backend_http_settings.value.request_timeout
      host_name             = lookup(backend_http_settings.value, "host_name", null)
      probe_name            = lookup(backend_http_settings.value, "probe_name", null)
    }
  }

  # HTTP listeners
  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "frontend-ip"
      frontend_port_name             = "https-port"
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_certificate_name
      host_name                      = lookup(http_listener.value, "host_name", null)
    }
  }

  # Request routing rules
  dynamic "request_routing_rule" {
    for_each = var.routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      url_path_map_name          = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }

  # WAF configuration
  waf_configuration {
    enabled                  = var.waf_enabled
    firewall_mode            = var.waf_firewall_mode
    rule_set_type            = var.waf_rule_set_type
    rule_set_version         = var.waf_rule_set_version
    file_upload_limit_mb     = var.waf_file_upload_limit_mb
    max_request_body_size_kb = var.waf_max_request_body_size_kb
  }

  # Health probes
  dynamic "probe" {
    for_each = var.health_probes
    content {
      name                = probe.value.name
      host                = lookup(probe.value, "host", null)
      interval            = probe.value.interval
      path                = probe.value.path
      protocol            = probe.value.protocol
      timeout             = probe.value.timeout
      unhealthy_threshold = probe.value.unhealthy_threshold
      match {
        status_code = probe.value.match_status_codes
      }
    }
  }

  # Enable diagnostic settings
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

# Diagnostic settings for App Gateway
resource "azurerm_monitor_diagnostic_setting" "appgw_diag" {
  name                       = "${var.app_gateway_name}-diagnostics"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ApplicationGatewayAccessLog"

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }

  metric {
    category = "AllMetrics"
    #enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_days
    }
  }
}
