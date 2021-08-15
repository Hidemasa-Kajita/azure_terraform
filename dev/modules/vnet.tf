# vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.service_name}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  /* ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos.id
    enable = true
  } */

  tags = {
    environment = var.env
  }
}
