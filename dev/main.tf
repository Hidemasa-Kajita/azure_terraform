terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.66.0"
    }
  }
}

# settion provider
provider "azurerm" {
  features {}
}

# resource group
resource "azurerm_resource_group" "dev-rg" {
  name     = "dev-rg"
  # location = "West US" // 遅すぎて草
  location = "Japan East"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_group" "dev-nsg" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_ddos_protection_plan" "dev-ddos-plan" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name
}

# vnet
resource "azurerm_virtual_network" "dev-vnet" {
  name                = "virtualNetwork1"
  location            = azurerm_resource_group.dev-rg.location
  resource_group_name = azurerm_resource_group.dev-rg.name
  address_space       = ["10.0.0.0/16"]
  # dns_servers         = ["10.0.0.4", "10.0.0.5"]

  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.dev-ddos-plan.id
    enable = true
  }

  tags = {
    environment = "dev"
  }
}

# subnet
resource "azurerm_subnet" "dev-subnet1" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.dev-rg.name
  virtual_network_name = azurerm_virtual_network.dev-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# public ip
resource "azurerm_public_ip" "dev-pip" {
  name                         = "myPublicIP"
  location                     = azurerm_resource_group.dev-rg.location
  resource_group_name          = azurerm_resource_group.dev-rg.name
  allocation_method            = "Static"

  tags = {
    environment = "dev"
  }
}

# nic
resource "azurerm_network_interface" "dev-nic" {
  name                        = "myNIC"
  location                    = azurerm_resource_group.dev-rg.location
  resource_group_name         = azurerm_resource_group.dev-rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.dev-subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev-pip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface_security_group_association" "deb-nica" {
  network_interface_id      = azurerm_network_interface.dev-nic.id
  network_security_group_id = azurerm_network_security_group.dev-nsg.id
}

resource "azurerm_ssh_public_key" "dev-key" {
  name                = "public-key"
  resource_group_name = azurerm_resource_group.dev-rg.name
  location            = azurerm_resource_group.dev-rg.location
  public_key          = file("./.ssh/ssh_key.pub")
}

resource "azurerm_linux_virtual_machine" "dev-vm" {
  name                            = "myVM"
  location                        = azurerm_resource_group.dev-rg.location
  resource_group_name             = azurerm_resource_group.dev-rg.name
  network_interface_ids           = [azurerm_network_interface.dev-nic.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_8-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username       = "azureuser"
    public_key     = azurerm_ssh_public_key.dev-key.public_key
  }

  connection {
    host = azurerm_public_ip.dev-pip.ip_address
    user = "azureuser"
    type = "ssh"
    private_key = file("./.ssh/ssh_key.pem")
    agent = true
  }

  provisioner "file" {
    source = "../deploy.sh"
    destination = "/home/azureuser/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/azureuser/deploy.sh",
      "/home/azureuser/deploy.sh"
    ]
  }

  tags = {
    environment = "dev"
  }
}
