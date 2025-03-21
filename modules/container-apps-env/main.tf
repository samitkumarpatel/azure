resource "azurerm_container_app_environment" "example" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

data "azurerm_storage_account" "example" {
  name                = var.storage.account_name
  resource_group_name = var.storage.account_resource_group_name
}

resource "azurerm_storage_share" "example" {
  for_each = toset(var.storage.share_name)

  name               = each.value
  storage_account_id = data.azurerm_storage_account.example.id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "example" {
  for_each = toset(var.storage.share_name)

  name                         = "app-env-${each.value}-storage"
  container_app_environment_id = azurerm_container_app_environment.example.id
  account_name                 = data.azurerm_storage_account.example.name
  share_name                   = each.value
  access_key                   = data.azurerm_storage_account.example.primary_access_key
  access_mode                  = "ReadWrite"
}
