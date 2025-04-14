resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.environment}-openai-log-analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = "${var.environment}-openai-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

# Action group for alerts
resource "azurerm_monitor_action_group" "notify_team" {
  name                = "notify-team"
  resource_group_name = var.resource_group_name
  short_name          = "notify-team"
  
  email_receiver {
    name          = "platform-team"
    email_address = var.alert_email
  }
  
  tags = var.tags
}

# Alert for high latency
resource "azurerm_monitor_metric_alert" "high_latency_alert" {
  name                = "high-latency-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.appgw_id]
  description         = "Alert when Application Gateway latency exceeds threshold"
  
  criteria {
    metric_namespace = "Microsoft.Network/applicationGateways"
    metric_name      = "BackendConnectTime"  # Updated metric name
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000 # 1 second in milliseconds
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.notify_team.id
  }
  
  tags = var.tags
}

# Alert for OpenAI quota usage
# In terraform/modules/monitoring/main.tf

# Replace the quota alert with a valid metric
resource "azurerm_monitor_metric_alert" "quota_alert" {
  name                = "openai-quota-alert"
  resource_group_name = var.resource_group_name
  scopes              = [var.openai_id]
  description         = "Alert when OpenAI service has high usage"
  
  criteria {
    metric_namespace = "Microsoft.CognitiveServices/accounts"
    metric_name      = "SuccessfulCalls"  # This is a valid metric for Cognitive Services
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.quota_alert_threshold
  }
  
  action {
    action_group_id = azurerm_monitor_action_group.notify_team.id
  }
  
  tags = var.tags
}