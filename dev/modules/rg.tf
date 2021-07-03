# resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.service_name}-${var.env}-rg"
  location = var.location

  tags = {
    environment = var.env
  }
}
