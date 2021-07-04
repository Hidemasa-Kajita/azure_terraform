resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.service_name}-${var.service_name}-vm"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = var.disk_size
  computer_name                   = "${var.service_name}${var.service_name}-vm"
  admin_username                  = var.admin_user

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.disk_type
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  admin_ssh_key {
    username       = var.admin_user
    public_key     = azurerm_ssh_public_key.ssh-key.public_key
  }

  connection {
    host = azurerm_public_ip.pip.ip_address
    user = var.admin_user
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
    environment = var.env
  }
}
