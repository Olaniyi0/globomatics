resource "random_integer" "zone" {
  count = var.number-of-vm
  seed = count.index
  min = 1
  max = 3
}

resource "azurerm_user_assigned_identity" "webservers-userid" {
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "webserver-user-assigned-id"
  resource_group_name = local.rg-name
  location            = local.rg-location
}

resource "azurerm_virtual_machine" "webserver" {
  count = var.number-of-vm
  depends_on = [
    azurerm_role_assignment.vm-blob-contributor,
    null_resource.blob_upload
  ]
  name                          = "webserver${count.index + 1}"
  resource_group_name           = local.rg-name
  location                      = local.rg-location
  delete_os_disk_on_termination = var.delete-os-disk-on-termination
  vm_size                       = var.vm-size
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]
  zones                         = var.vm-availability-zones[random_integer.zone[count.index].result]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "webserver${count.index + 1}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.computer-name}${count.index + 1}"
    admin_username = var.admin-username
    admin_password = var.admin_password
    custom_data    = <<-EOF
    sudo apt -y update
    sudo apt -y install nginx
    echo "export AZCOPY_AUTO_LOGIN_TYPE=MSI" | tee -a ~/.bashrc
    echo "export AZCOPY_MSI_msiid=${azurerm_user_assigned_identity.webservers-userid.id}" | tee -a ~/.bashrc
    echo "alias azcopy=./azcopy" | tee -a ~/.bashrc
    source /root/.bashrc
    sudo wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1
    azcopy copy https://${var.storage-account-name}.blob.core.windows.net/${local.container-name}/ . --recursive
    sudo rm -r /var/www/html && sudo mv ${local.container-name} html && sudo cp -r html /var/www/
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


# resource "null_resource" "startup-script" {
#   provisioner "remote-exec" {
#     connection {
#     type     = "ssh"
#     user     = var.admin-username
#     password = var.admin_password
#     host     = self.public_ip
#   }
#     inline = [
#       "sudo apt -y update",
#       "sudo apt -y install nginx",
#       "wget -O azcopy_v10.tar.gz https://aka.ms/downloadazcopy-v10-linux && tar -xf azcopy_v10.tar.gz --strip-components=1",
#       "export AZCOPY_AUTO_LOGIN_TYPE=MSI",
#       "export export AZCOPY_MSI_msiid=${azurerm_user_assigned_identity.webservers-userid.id}",
#       "sudo echo export azcopy=./azcopy >> .bashrc",
#       "source .bashrc",
#       "azcopy copy https://${var.storage-account-name}.blob.core.windows.net/${local.container-name}/ . --recursive",
#       "sudo rm -r /var/www/html",
#       "sudo mv ${local.container-name} html",
#       "sudo cp -r html /var/www/ "
#     ]
#   }  
# }
