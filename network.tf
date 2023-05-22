resource "azurerm_resource_group" "globomatics-rg" {
  name     = local.rg-name
  location = local.rg-location
  tags     = local.common-tags
}

resource "azurerm_virtual_network" "globomatics-network" {
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "globomatics-network"
  resource_group_name = local.rg-name
  location            = local.rg-location
  address_space       = var.network-address-space
}

resource "azurerm_subnet" "subnet1" {
  depends_on           = [azurerm_virtual_network.globomatics-network]
  name                 = "subnet1"
  resource_group_name  = local.rg-name
  virtual_network_name = azurerm_virtual_network.globomatics-network.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "frontend" {
  depends_on           = [azurerm_virtual_network.globomatics-network]
  name                 = "AGSsubnet"
  resource_group_name  = local.rg-name
  virtual_network_name = azurerm_virtual_network.globomatics-network.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_network_security_group" "allowInboundTCP" {
  depends_on          = [azurerm_virtual_network.globomatics-network]
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
  depends_on                = [azurerm_network_security_group.allowInboundTCP]
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.allowInboundTCP.id
}

resource "azurerm_public_ip" "vm-public-ip" {
  count = var.number-of-vm
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
  count = var.number-of-vm
  depends_on          = [azurerm_subnet.subnet1]
  name                = "nic${count.index}"
  resource_group_name = local.rg-name
  location            = local.rg-location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-public-ip[count.index].id
  }
}
