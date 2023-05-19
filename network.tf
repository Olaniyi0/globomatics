resource "azurerm_resource_group" "globomatics-rg" {
  name     = local.rg-name
  location = local.rg-location
  tags     = local.common-tags
}

resource "azurerm_virtual_network" "globomatics-network" {
  depends_on = [ azurerm_resource_group.globomatics-rg ]
  name                = "globomatics-network"
  resource_group_name = local.rg-name
  location            = local.rg-location
  address_space       = var.network-address-space
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = local.rg-name
  virtual_network_name = azurerm_virtual_network.globomatics-network.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "AGSsubnet"
  resource_group_name  = local.rg-name
  virtual_network_name = azurerm_virtual_network.globomatics-network.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_network_security_group" "allowInboundTCP" {
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

resource "azurerm_subnet_network_security_group_association" "subnet1AllowTCP" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.allowInboundTCP.id
}

resource "azurerm_public_ip" "vm1-public-ip" {
  name                = "vm1-public-ip"
  resource_group_name = local.rg-name
  location            = local.rg-location
  allocation_method   = "Static"
  zones               = ["2"]
  sku                 = "Standard"
}

resource "azurerm_public_ip" "lb-pip" {
  name                = "lb-pip"
  resource_group_name = local.rg-name
  location            = local.rg-location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  resource_group_name = local.rg-name
  location            = local.rg-location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1-public-ip.id
  }
}


resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  resource_group_name = local.rg-name
  location            = local.rg-location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
  }
}


