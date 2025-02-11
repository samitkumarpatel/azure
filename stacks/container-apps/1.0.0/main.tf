resource "azurerm_resource_group" "stack_1_0_0" {
  name     = "example-resources01"
  location = "West Europe"
}

module "log_analytics" {
  source              = "../../../modules/log-analytics"
  name                = var.log_analytics_name
  location            = azurerm_resource_group.stack_1_0_0.location
  resource_group_name = azurerm_resource_group.stack_1_0_0.name
}

module "container_app_environment" {
  source                     = "../../../modules/container-app-environment"
  name                       = var.container_app_environment_name
  location                   = azurerm_resource_group.stack_1_0_0.location
  resource_group_name        = azurerm_resource_group.stack_1_0_0.name
  log_analytics_workspace_id = module.log_analytics.id
}

# possibly this module will be Iterated over a list of container apps
module "container_app" {
  source                       = "../../../modules/container-app"
  name                         = "example-app"
  container_app_environment_id = module.container_app_environment.container_app_environment_id
  resource_group_name          = azurerm_resource_group.stack_1_0_0.name
  registry_password            = "example-password"
  container = {
    name  = "example-container"
    image = "nginx"
    env = {
      "EXAMPLE_ENV_VAR" = "example-value"
    }
  }

  ingress = {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = 80
    transport                  = "auto"
  }
}
