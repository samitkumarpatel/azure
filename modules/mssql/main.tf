resource "random_password" "pass" {
  length = 20
}

resource "azurerm_mssql_server" "example" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = random_password.pass.result
  minimum_tls_version          = "1.2"

}

resource "azurerm_mssql_database" "example" {
  depends_on   = [azurerm_mssql_server.example]
  for_each     = toset(var.database_names)
  
  name         = each.value
  server_id    = azurerm_mssql_server.example.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  #license_type = "LicenseIncluded"
  sku_name     = "GP_S_Gen5_2"
  max_size_gb = 32

  storage_account_type = "Local"
}