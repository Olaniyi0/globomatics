output "webserver-public-ip" {
  value = [for address in azurerm_public_ip.vm-public-ip: address.ip_address]
}

output "loadbalancer-public-ip" {
  value = azurerm_public_ip.lb-pip.ip_address
}
