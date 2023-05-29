output "webserver-public-ip" {
  value = azurerm_public_ip.vm-public-ip[*].ip_address
}

output "loadbalancer-public-ip" {
  value = azurerm_public_ip.lb-pip.ip_address
}
