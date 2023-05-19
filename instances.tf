resource "azurerm_user_assigned_identity" "webservers-userid" {
  depends_on = [ azurerm_resource_group.globomatics-rg ]
  name                = "webserver-user-assigned-id"
  resource_group_name = local.rg-name
  location            = local.rg-location
}

resource "azurerm_virtual_machine" "webserver1" {
  depends_on = [
    azurerm_role_assignment.vm1-blob-contributor,
    null_resource.blob_upload
  ]
  name                          = "webserver1"
  resource_group_name           = local.rg-name
  location                      = local.rg-location
  delete_os_disk_on_termination = var.delete-os-disk-on-termination
  vm_size                       = var.vm-size
  network_interface_ids         = [azurerm_network_interface.nic1.id]
  zones                         = var.vm-availability-zones[1]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "webserver1-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer-name
    admin_username = var.admin-username
    admin_password = var.admin_password
    custom_data    = <<-EOF
    #!/bin/bash
    sudo apt -y update
    sudo apt -y install nginx
    sudo wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
    sudo echo export AZCOPY_AUTO_LOGIN_TYPE=MSI >> .bashrc
    sudo echo export AZCOPY_MSI_msiid="${azurerm_user_assigned_identity.webservers-userid.id}" >> .bashrc
    sudo echo export azcopy=./azcopy >> .bashrc
    source .bashrc
    azcopy copy "https://${var.storage-account-name}.blob.core.windows.net/${local.container-name}/" "./" --recursive
    sudo rm -r /var/www/html
    sudo mv ${local.container-name} html
    sudo cp -r html /var/www/ 
  EOF
  }
  os_profile_linux_config {
    disable_password_authentication = var.disable-password-auth
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.webservers-userid.id]
  }
}

resource "azurerm_virtual_machine" "webserver2" {
  depends_on = [
    azurerm_role_assignment.vm2-blob-contributor,
    null_resource.blob_upload
  ]
  name                          = "webserver2"
  resource_group_name           = local.rg-name
  location                      = local.rg-location
  delete_os_disk_on_termination = var.delete-os-disk-on-termination
  vm_size                       = var.vm-size
  network_interface_ids         = [azurerm_network_interface.nic2.id]
  zones                         = var.vm-availability-zones[0]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "webserver2-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.computer-name2
    admin_username = var.admin-username
    admin_password = var.admin_password
    custom_data    = <<-EOF
    #!/bin/bash
    sudo apt -y update
    sudo apt -y install nginx
    wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
    export AZCOPY_AUTO_LOGIN_TYPE=MSI
    export export AZCOPY_MSI_msiid="${azurerm_user_assigned_identity.webservers-userid.id}"
    ./azcopy copy "https://${var.storage-account-name}.blob.core.windows.net/${local.container-name}/" "./" --recursive
    sudo cp -r ${local.container-name} /var/www/html/
    sudo rm /var/www/html/index.nginx-debian.html
  EOF
  }
  os_profile_linux_config {
    disable_password_authentication = var.disable-password-auth
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.webservers-userid.id]
  }
}
