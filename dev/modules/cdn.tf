# cdn プロファイル作成
## TODO: 繋がらないので調査が必要
resource "azurerm_cdn_profile" "cdn" {
  name                = "${var.service_name}-cdn"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_Verizon"
}

# cdn エンドポイント作成
resource "azurerm_cdn_endpoint" "cdn-endpoint" {
  name                = "${var.service_name}-endpoint"
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # storage から配信
  origin {
    name      = "example"
    host_name = "${var.service_name}storagemwncejkdlsnv.blob.core.windows.net"
  }
  origin_host_header = "${var.service_name}storagemwncejkdlsnv.blob.core.windows.net"
}