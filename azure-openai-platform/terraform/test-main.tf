terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_cognitive_account" "openai" {
  name                = "my-openai-service"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "gpt35_turbo" {
  name                 = "gpt-35-turbo-0125"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0125"
  }
  scale {
    type = "Standard"
  }
}

resource "azurerm_cognitive_deployment" "gpt4" {
  name                 = "gpt-4-0613"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }
  scale {
    type = "Standard"
  }
}

resource "azurerm_databricks_workspace" "databricks" {
  name                = "mosaic-ai-workspace"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "premium"
}


# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "openai-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "openai-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Kong API Gateway (Container Instance)
# Add ACR resource
resource "azurerm_container_registry" "acr" {
  name                = "mykongacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Update Kong Container Group to use ACR
resource "azurerm_container_group" "kong" {
  name                = "kong-api-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "kong-api"
  os_type             = "Linux"

  container {
    name   = "kong"
    image  = "mykongacr.azurecr.io/kong:3.6"
    cpu    = "1.0"
    memory = "1.5"

    ports {
      port     = 8000
      protocol = "TCP"
    }

    environment_variables = {
      "KONG_DATABASE"      = "off"
      "KONG_PROXY_LISTEN"  = "0.0.0.0:8000"
      "KONG_ADMIN_LISTEN"  = "0.0.0.0:8001"
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  depends_on = [azurerm_container_registry.acr]
}
# Public IP for App Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "openai-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  ssl_certificate {
    name = "my-ssl-cert"  # ensure that the certificate is uploaded at azure
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name  = "kong-pool"
    fqdns = [azurerm_container_group.kong.fqdn]
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 8000
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "my-ssl-cert"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "httpa-listener"
    backend_address_pool_name  = "kong-pool"
    backend_http_settings_name = "http-settings"
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}


resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "openai-log-analytics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_diagnostic_setting" "appgw_diag" {
  name                       = "appgw-diagnostics"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id

  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_monitor_metric_alert" "quota_alert" {
  name                = "quota-alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_cognitive_account.openai.id]
  description         = "Alert on high request count"

  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "TotalCalls"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 100
  }

  window_size = "PT5M"  # Corrected from time_window
  action {
    action_group_id = azurerm_monitor_action_group.notify_team.id
  }

  frequency   = "PT1M"  # Evaluate every minute
  severity    = 3       # Medium severity
}

resource "azurerm_monitor_action_group" "notify_team" {
  name                = "notify-team"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "notifyteam"

  email_receiver {
    name          = "team-email"
    email_address = "team@domain.com"
  }
}
