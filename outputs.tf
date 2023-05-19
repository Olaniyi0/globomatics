output "webserver-public-ip" {
  value = azurerm_public_ip.vm1-public-ip.ip_address
}

output "loadbalancer-public-ip" {
  value = azurerm_public_ip.lb-pip.ip_address
}
