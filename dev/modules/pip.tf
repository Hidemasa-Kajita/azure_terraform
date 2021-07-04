# public ip
resource "azurerm_public_ip" "pip" {
  name                         = "${var.service_name}-pip"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Static"

  tags = {
    environment = var.env
  }
}

# public ip
resource "azurerm_public_ip" "lb-pip" {
  name                         = "${var.service_name}-lb-pip"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Static"
  sku = "Standard"

  tags = {
    environment = var.env
  }
}

