resource "random_integer" "rand" {
  min = 10000
  max = 99999
  # keepers = {
  #   # Generate a new integer each time we switch to a new listener ARN
  #   listener_arn = var.listener_arn
  # }
}

locals {
  rg-location = var.resource-group-location
  rg-name     = var.resource-group-name
  common-tags = {
    enviroment = var.enviroment-name
    project    = var.project-name
    company    = var.company-name
  }

  # loadbalancer locals
  backend_address_pool_name      = "webserver-AGS-beap"
  frontend_port_name             = "webserver-AGS-feport"
  frontend_ip_configuration_name = "webserver-AGS-feip"
  http_setting_name              = "webserver-AGS-be-htst"
  listener_name                  = "webserver-AGS-httplstn"
  request_routing_rule_name      = "webserver-AGS-rqrt"
  redirect_configuration_name    = "webserver-AGS-rdrcfg"

  # storage container
  container-name = "web-resources-${random_integer.rand.result}"
}