output "fqdn" {
  value = azurerm_container_app.example.ingress[0].fqdn
}