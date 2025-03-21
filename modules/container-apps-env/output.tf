output "container_app_environment_id" {
    value =  azurerm_container_app_environment.example.id
}

output "environment_storage_name" {
    value = [for s in azurerm_container_app_environment_storage.example : s.name]
}

