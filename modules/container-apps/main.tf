resource "azurerm_container_app" "example" {
  name                         = var.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  dynamic "secret" {
    for_each = var.registry_password != null ? [1] : []
    content {
      name  = "registry-credentials-id"
      value = var.registry_password
    }
  }
  
  dynamic "registry" {
    for_each = var.registry_password != null ? [1] : []
    content {
      server = "ghcr.io"
      username = "samitkumarpatel"
      password_secret_name = "registry-credentials-id"
    }
  }
  
  
  template {
    min_replicas = 1
    max_replicas = 2
    container {
      name   = var.container.name
      image  = var.container.image
      cpu    = var.container.cpu
      memory = var.container.memory
      
      dynamic "env" {
        for_each = [for key, value in var.container.env : { name = key, value = value }]
        content {
          name  = env.value.name
          value = env.value.value
        }  
      }
      
    }
  }

  ingress {
    allow_insecure_connections = var.ingress.allow_insecure_connections
    external_enabled = var.ingress.external_enabled
    target_port = var.ingress.target_port
    exposed_port = var.ingress.exposed_port
    transport = var.ingress.transport
    traffic_weight {
        latest_revision = true
        percentage = 100
    }
  }
}