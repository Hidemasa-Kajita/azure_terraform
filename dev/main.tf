terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
    }
  }
}

# settion provider
provider "azurerm" {
  features {}
}

module "base" {
  env          = var.env
  service_name = var.service_name
  location     = var.location
  disk_size    = var.disk_size
  admin_user   = var.admin_user
  disk_type    = var.disk_type
  vm_publisher = var.vm_publisher
  vm_offer     = var.vm_offer
  vm_sku       = var.vm_sku
  vm_version   = var.vm_version

  source = "./modules"
}
