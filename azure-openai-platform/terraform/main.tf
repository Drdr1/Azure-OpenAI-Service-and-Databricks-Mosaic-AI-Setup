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

