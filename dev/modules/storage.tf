# ストレージアカウント
resource "azurerm_storage_account" "storage-acount" {
  name                     = "${var.service_name}storagemwncejkdlsnv"
  location = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  allow_blob_public_access = true
  tags = {
    environment = var.env
  }
}

# 画像を保存するコンテナ
resource "azurerm_storage_container" "img-container" {
  name                  = "content"
  storage_account_name  = azurerm_storage_account.storage-acount.name
  container_access_type = "container"
  # container_access_type = "private" // 将来的にこっちにしたい。その場合`allow_blob_public_access=false`にする
  # アプリを作る（dnsを設定する）時にcorsも設定
}

# azコンテナ内の操作ができる権限付与
resource "azurerm_role_assignment" "data-contributor-role" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.client.object_id
}
