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
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources01"
  location = "West Europe"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "Example-Environment"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "nginx"
      image  = "nginx"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled = true
    target_port = 80
    transport = "auto"
    traffic_weight {
        latest_revision = true
        percentage = 100
    }
  }
}
output "nginx_ingress" {
  value = azurerm_container_app.example.ingress[0].fqdn
  
}

resource "azurerm_container_app" "mongodb" {
  name                         = "mongodb-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "mongo"
      image  = "mongo"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name  = "MONGO_INITDB_ROOT_USERNAME"
        value = "root"
      }
      env {
        name  = "MONGO_INITDB_ROOT_PASSWORD"
        value = "example"
      }
    }
  }

  ingress {
    external_enabled = false
    target_port = 27017
    exposed_port = 27017
    transport = "tcp"
    traffic_weight {
        latest_revision = true
        percentage = 100
    }
  }
}

output "mongodb_ingress" {
  value = azurerm_container_app.mongodb.ingress[0].fqdn
}

resource "azurerm_container_app" "mongodb_express" {
  name                         = "mongodb-express"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
        name   = "mongo-express"
        image  = "mongo-express"
        cpu    = 0.25
        memory = "0.5Gi"
        env {
            name  = "ME_CONFIG_MONGODB_URL"
            value = "mongodb://root:example@${azurerm_container_app.mongodb.ingress[0].fqdn}:27017/"
        }
        env {
            name  = "ME_CONFIG_BASICAUTH"
            value = "false"
        }
        env {
            name  = "ME_CONFIG_MONGODB_ADMINUSERNAME"
            value = "root"
        }
        env {
            name  = "ME_CONFIG_MONGODB_ADMINPASSWORD"
            value = "example"
        }
    }
  }

  ingress {
    allow_insecure_connections = true
    external_enabled = true
    target_port = 8081
    transport = "auto"
    traffic_weight {
        latest_revision = true
        percentage = 100
    }
  }
}

output "mongodb_express" {
  value = azurerm_container_app.mongodb_express.ingress[0].fqdn
}