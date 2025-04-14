resource "azurerm_container_group" "kong" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_address_type     = "Public"
  dns_name_label      = lower(replace(var.name, "-", ""))
  os_type             = "Linux"
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }
 
  image_registry_credential {
    server   = "${var.acr_name}.azurecr.io"
    username = var.acr_admin_username
    password = var.acr_admin_password
  }
  
  container {
    name   = "kong"
    image  = "${var.acr_name}.azurecr.io/kong:3.3.1"
    cpu    = "1.0"
    memory = "1.5"
    
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
      "KONG_DATABASE"    = "off"
      "KONG_PROXY_ACCESS_LOG" = "/dev/stdout"
      "KONG_ADMIN_ACCESS_LOG" = "/dev/stdout"
      "KONG_PROXY_ERROR_LOG"  = "/dev/stderr"
      "KONG_ADMIN_ERROR_LOG"  = "/dev/stderr"
      "KONG_ADMIN_LISTEN"     = "0.0.0.0:8001, 0.0.0.0:8444 ssl"
    }
  }
  
  tags = var.tags
}

