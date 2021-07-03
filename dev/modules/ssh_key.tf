resource "azurerm_ssh_public_key" "ssh-key" {
  name                = "${var.service_name}-ssh-key"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = file("./.ssh/ssh_key.pub")

  tags = {
    environment = var.env
  }
}
