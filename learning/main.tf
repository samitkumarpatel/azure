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

  backend "azurerm" {
    resource_group_name  = "personal"
    storage_account_name = "azstrogeu001"
    container_name       = "tfstate"
    key                  = "learning.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "learn-resources01"
  location = "West Europe"
}

locals {
  storage = {
    account_name                = "azstrogeu001"
    account_resource_group_name = "personal"
    share_name                  = []
  }
}

module "postgres" {
  source              = "../modules/postgres-flex"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  server_name         = "learn-postgres"
  database_names      = ["person", "todo"]
  ip_address          = ["0.0.0.0"]
}

output "postgres_endpoint" {
  value = module.postgres.endpoint
}

module "apps_env" {
  source              = "../modules/container-apps-env"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "learn-env"
  storage             = local.storage
}

output "apps_env" {
  value = module.apps_env.container_app_environment_id
}


# module "container_apps_postgres" {
#   depends_on = [module.apps_env]

#   source                       = "../modules/container-apps"
#   resource_group_name          = azurerm_resource_group.test.name
#   container_app_environment_id = module.apps_env.container_app_environment_id
#   name                         = "postgres-app"

#   app_env_storage_name = null
#   volumes              = []

#   container = {
#     name  = "postgres"
#     image = "postgres"
#     env = {
#       POSTGRES_USER     = "root"
#       POSTGRES_PASSWORD = "example"
#       POSTGRES_DB       = "person"
#     }
#     volume = {}
#   }
#   ingress = {
#     allow_insecure_connections = null
#     external_enabled           = false
#     target_port                = 5432
#     exposed_port               = 5432
#     transport                  = "tcp"
#   }
# }

variable "registry_password" {}

module "container_apps_person" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "person-app"
  registry_password            = var.registry_password
  container = {
    name  = "peron"
    image = "ghcr.io/fullstack1o1/person:170520252048"
    env = {
      "spring.datasource.url"      = "jdbc:postgresql://${module.postgres.endpoint}/person"
      "spring.datasource.username" = "psqladmin"
      "spring.datasource.password" = module.postgres.password
      "spring.flyway.enabled"      = true
    }
    volume = {}
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
  }

}


output "person_api_url" {
  value = module.container_apps_person.fqdn
}

module "container_apps_todo" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "todo-app"
  registry_password            = var.registry_password

  container = {
    name  = "todo"
    image = "ghcr.io/fullstack1o1/todo:110520252133"
    env = {
      "spring.datasource.url"      = "jdbc:postgresql://${module.postgres.endpoint}/todo"
      "spring.datasource.username" = "psqladmin"
      "spring.datasource.password" = module.postgres.password
      "spring.flyway.enabled"      = true
    }
    volume = {}
  }
  ingress = {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
  }

}


output "todo_api_url" {
  value = module.container_apps_todo.fqdn
}
