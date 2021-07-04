# ALB
resource "azurerm_lb" "lb" {
  name                = "${var.service_name}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}

# バックエンドプール
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

# NATインバウンドルール
## VMが追加されていない（踏み台使おうと思うのでとりあえず良い）。どこかで消す。
resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
}

# 負荷分散ルール
resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip = false
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  idle_timeout_in_minutes = 5
  probe_id = azurerm_lb_probe.lb_probe.id
}

# 正常性ブローブ
resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "tcpProbe"
  protocol = "Tcp"
  port                = 80
  interval_in_seconds = 5
}

# バックエンドプールに含まれるipアドレス（VM）
resource "azurerm_lb_backend_address_pool_address" "lb-backend-private-address" {
  name                    = "example"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  virtual_network_id      = azurerm_virtual_network.vnet.id
  ip_address              = azurerm_linux_virtual_machine.vm.private_ip_address
}