# nic
resource "azurerm_network_interface" "nic" {
  name                        = "${var.service_name}-nic"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.service_name}-nic-ip-conf"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    # public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = {
    environment = var.env
  }
}
