locals {
  frontend_ip_configuration_name = "appGwPublicFrontendIp"
  frontend_port_name            = "appGwFrontendPort"
  backend_address_pool_name     = "appGwBackendPool"
  http_setting_name             = "appGwHttpSetting"
  listener_name                 = "appGwListener"
  request_routing_rule_name     = "appGwRoutingRule"
  probe_name                    = "appGwProbe"
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_web_application_firewall_policy" "this" {
  name                = "${var.name}-waf-policy"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }
  
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  
  tags = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = "appGwIpConfig"
    subnet_id = var.subnet_id
  }
  
  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.this.id
  }
  
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  
  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [var.backend_ip_address]
  }
  
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 8000
    protocol              = "Http"
    request_timeout       = 60
    probe_name            = local.probe_name
  }
  
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  
  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 100
  }
  
  probe {
    name                = local.probe_name
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    protocol            = "Http"
    port                = 8000
    path                = "/"
  }
  
  firewall_policy_id = azurerm_web_application_firewall_policy.this.id
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }
  
  tags = var.tags
}