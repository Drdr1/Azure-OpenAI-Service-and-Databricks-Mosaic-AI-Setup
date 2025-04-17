resource "azurerm_virtual_network" "this" {
  name                = "${var.environment}-openai-vnet"
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnet_prefixes
  
  name                 = "${each.key}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value
  
  # Add service endpoints based on subnet type
  service_endpoints    = lookup(var.service_endpoints, each.key, [])
  
  # Add delegation for container subnet
  dynamic "delegation" {
    for_each = each.key == "container" ? [1] : []
    content {
      name = "delegation"
      
      service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

# Network Security Group for OpenAI subnet
resource "azurerm_network_security_group" "openai_nsg" {
  name                = "${var.environment}-openai-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowed_ip_ranges
    destination_address_prefix = "*"
  }
  
  tags = var.tags
}

# Associate NSG with OpenAI subnet
resource "azurerm_subnet_network_security_group_association" "openai_subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnets["openai"].id
  network_security_group_id = azurerm_network_security_group.openai_nsg.id
}