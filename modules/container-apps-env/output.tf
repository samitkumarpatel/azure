output "container_app_environment_id" {
    value =  azurerm_container_app_environment.example.id
}

output "storage_names" {
    value = [for s in azurerm_container_app_environment_storage.example : s.name]
}

