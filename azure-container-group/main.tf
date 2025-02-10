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
  name     = "example-resources00"
  location = "West Europe"
}

resource "random_string" "container_name" {
  length  = 25
  lower   = true
  upper   = false
  special = false
}

resource "random_uuid" "example" {}
resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-log-analytics-workspace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_container_group" "example" {
  depends_on          = [azurerm_log_analytics_workspace.example]
  name                = "example-continst"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "Public"
  #dns_name_label      = "aci-label"
  os_type = "Linux"

  container {
    name   = "hello-cloud"
    image  = "ghcr.io/samitkumarpatel/hello-cloud-fe:main"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

    container {
      name   = "sidecar"
      image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
      cpu    = "0.5"
      memory = "1.5"
    }

  diagnostics {
    log_analytics {
      workspace_id  = azurerm_log_analytics_workspace.example.workspace_id
      workspace_key = azurerm_log_analytics_workspace.example.primary_shared_key
    }
  }

  tags = {
    environment = "testing"
  }
}

output "container_ipv4_address" {
  value = azurerm_container_group.example.ip_address
}


