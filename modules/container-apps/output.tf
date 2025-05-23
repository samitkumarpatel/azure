output "fqdn" {
  value = azurerm_container_app.example.ingress[0].fqdn
}

output "egress_ip" {
  value = azurerm_container_app.example.outbound_ip_addresses
}