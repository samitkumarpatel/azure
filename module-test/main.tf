terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "example-resources01"
  location = "West Europe"
}

module "apps_env" {
  source              = "../modules/container-apps-env"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "test-apps-env"
  storage_share_name  = "test-share"
}

output "apps_env" {
  value = module.apps_env.container_app_environment_id
}

module "container_apps" {
  depends_on                   = [module.apps_env]
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "nginx-app"
  environment_storage_name     = module.apps_env.environment_storage_name
  volumes = [
    "cache-volume", "logs-volume"
  ]
  container = {
    name  = "nginx-container"
    image = "nginx"
    env = {
      ENV_ONE = "One"
      ENV_TWO = "Two"
    }
    volume = {
      cache-volume = "/var/cache/nginx"
    }
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 80
    transport                  = "http"
  }

}
