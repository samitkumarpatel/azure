terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
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

module "apps_env" {
  source              = "../modules/container-apps-env"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  name                = "learn-env"
}

output "apps_env" {
  value = module.apps_env.container_app_environment_id
}


module "container_apps_postgres" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "postgres-app"
  container = {
    name  = "postgres"
    image = "postgres"
    env = {
      POSTGRES_USER     = "root"
      POSTGRES_PASSWORD = "example"
      POSTGRES_DB       = "person"
    }
  }
  ingress = {
    allow_insecure_connections = null
    external_enabled           = false
    target_port                = 5432
    exposed_port               = 5432
    transport                  = "tcp"
  }

}

variable "registry_password" {}

module "container_apps_person" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "person-app"
  registry_password            = var.registry_password
  container = {
    name  = "peron"
    image = "ghcr.io/fullstack1o1/person:210220252208"
    env = {
      "spring.datasource.url"      = "jdbc:postgresql://postgres-app:5432/person"
      "spring.datasource.username" = "root"
      "spring.datasource.password" = "example"
      "spring.flyway.enabled"      = true
    }
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

module "container_apps_postgres_todo" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "postgres-todo"
  container = {
    name  = "postgres"
    image = "postgres"
    env = {
      POSTGRES_USER     = "root"
      POSTGRES_PASSWORD = "example"
      POSTGRES_DB       = "todo"
    }
  }
  ingress = {
    allow_insecure_connections = null
    external_enabled           = false
    target_port                = 5432
    exposed_port               = 5432
    transport                  = "tcp"
  }

}

module "container_apps_todo" {
  source                       = "../modules/container-apps"
  resource_group_name          = azurerm_resource_group.test.name
  container_app_environment_id = module.apps_env.container_app_environment_id
  name                         = "todo-app"
  registry_password            = var.registry_password
  container = {
    name  = "todo"
    image = "ghcr.io/fullstack1o1/todo:main"
    env = {
      "spring.datasource.url"      = "jdbc:postgresql://postgres-todo:5432/todo"
      "spring.datasource.username" = "root"
      "spring.datasource.password" = "example"
      "spring.flyway.enabled"      = true
    }
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