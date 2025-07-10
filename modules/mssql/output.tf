output "server_id" {
    value = azurerm_mssql_server.example.id
}

output "fully_qualified_domain_name" {
  value = azurerm_mssql_server.example.fully_qualified_domain_name
}

output "username" {
  value = azurerm_mssql_server.example.administrator_login
}

output "password" {
  value     = random_password.pass.result
  sensitive = true
}