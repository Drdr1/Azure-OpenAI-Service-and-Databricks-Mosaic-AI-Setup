resource "random_string" "openai_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_cognitive_account" "openai" {
  name                  = "openai-service"
  location              = var.location
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = lower("openai-${random_string.openai_suffix.result}")
  
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }
  
  network_acls {
    default_action = "Deny"
    ip_rules       = var.allowed_ip_ranges
    virtual_network_rules {
      subnet_id = var.subnet_id
    }
  }
  
  tags = var.tags
}

resource "azurerm_key_vault_secret" "openai_key" {
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai.primary_access_key
  key_vault_id = var.key_vault_id
}

# OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "gpt35" {
  name                 = "gpt-35-turbo-0125"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0125"
  }
  
  sku {
    name     = "Standard"
    capacity = var.gpt35_capacity
  }
}

resource "azurerm_cognitive_deployment" "gpt4" {
  name                 = "gpt-4"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  
  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "0613"
  }
  sku {
    name     = "Standard"
    capacity = var.gpt4_capacity
    
  }
  
}  