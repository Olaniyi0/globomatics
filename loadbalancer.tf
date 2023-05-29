resource "azurerm_application_gateway" "webserver-gateway" {
  depends_on          = [module.network]
  name                = "webserver-gateway"
  resource_group_name = local.rg-name
  location            = local.rg-location
  tags                = local.common-tags
  # zones               = var.lb-availability-zone

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "webserver-gateway-ip-configuration"
    subnet_id = module.network.vnet_subnets[1]
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = [for nic in azurerm_network_interface.nic : nic.private_ip_address]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

resource "azurerm_monitor_diagnostic_setting" "app-gateway-log" {
  depends_on         = [azurerm_application_gateway.webserver-gateway]
  name               = "app-gateway-access-logs"
  target_resource_id = azurerm_application_gateway.webserver-gateway.id
  storage_account_id = module.globomatics_storage.storage_account.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
    retention_policy {
      enabled = true
      days    = 0
    }
  }
}