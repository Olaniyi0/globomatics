resource "azurerm_resource_group" "globomatics-rg" {
  name     = local.rg-name
  location = local.rg-location
  tags     = local.common-tags
}

module "network" {
  source              = "Azure/network/azurerm"
  version             = "=5.2.0"
  vnet_name           = "${local.common-tags.project}-vnet"
  resource_group_name = local.rg-name
  address_space       = var.network-address-space[terraform.workspace]
  subnet_prefixes     = [for netnum in range(var.vpc-subnet-count[terraform.workspace]) : cidrsubnet(var.network-address-space[terraform.workspace], 8, netnum+1)]
  subnet_names        = [for num in range(var.vpc-subnet-count[terraform.workspace]) : "subnet${num + 1}"]

  use_for_each = true
  tags         = local.common-tags

  depends_on = [azurerm_resource_group.globomatics-rg]
}


resource "azurerm_network_security_group" "allowInboundTCP" {
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "allowInboundTCP"
  resource_group_name = local.rg-name
  location            = local.rg-location
  security_rule {
    name                       = "allowHTTPSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "8080", "443", "22"]
  }
}

resource "azurerm_subnet_network_security_group_association" "subnetsAllowTCP" {
  depends_on                = [azurerm_network_security_group.allowInboundTCP]
  count                     = var.vpc-subnet-count[terraform.workspace]
  subnet_id                 = module.network.vnet_subnets[count.index]
  network_security_group_id = azurerm_network_security_group.allowInboundTCP.id
}

resource "azurerm_public_ip" "vm-public-ip" {
  count               = var.number-of-vm[terraform.workspace]
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "vm${count.index + 1}-pip"
  resource_group_name = local.rg-name
  location            = local.rg-location
  allocation_method   = "Static"
  zones               = [random_integer.zone[count.index].result]
  sku                 = "Standard"
}

resource "azurerm_public_ip" "lb-pip" {
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "lb-pip"
  resource_group_name = local.rg-name
  location            = local.rg-location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count               = var.number-of-vm[terraform.workspace]
  depends_on          = [module.network]
  name                = "nic${count.index + 1}"
  resource_group_name = local.rg-name
  location            = local.rg-location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-public-ip[count.index].id
  }
}
