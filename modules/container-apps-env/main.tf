resource "azurerm_container_app_environment" "example" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

data "azurerm_storage_account" "example" {
  name                = "azstrogeu001"
  resource_group_name = "personal"
}

resource "azurerm_storage_share" "example" {
  name               = var.storage_share_name
  storage_account_id = data.azurerm_storage_account.example.id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "example" {
  name                         = "${var.name}-storage"
  container_app_environment_id = azurerm_container_app_environment.example.id
  account_name                 = data.azurerm_storage_account.example.name
  share_name                   = azurerm_storage_share.example.name
  access_key                   = data.azurerm_storage_account.example.primary_access_key
  access_mode                  = "ReadWrite"
}
