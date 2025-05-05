output "name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.example.name
}

output "endpoint" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.example.fqdn
}

output "password" {
  description = "The password for the PostgreSQL Flexible Server administrator."
  value       = random_password.pass.result
  sensitive   = true
}
