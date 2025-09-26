resource "random_password" "pass" {
  length = 20
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                          = var.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "17"
  public_network_access_enabled = true
  administrator_login           = "psqladmin"
  administrator_password        = random_password.pass.result
  zone                          = "1"
  geo_redundant_backup_enabled  = false
  auto_grow_enabled             = false

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "example" {
  count               = length(var.database_names)

  name      = var.database_names[count.index]
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  depends_on = [ azurerm_postgresql_flexible_server.example ]
}
