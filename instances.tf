resource "random_integer" "zone" {
  count = var.number-of-vm[terraform.workspace]
  seed  = count.index
  min   = 1
  max   = 3
}

resource "random_pet" "pet_name" {
  length    = 1
  separator = ""
}

resource "azurerm_user_assigned_identity" "webservers-userid" {
  depends_on          = [azurerm_resource_group.globomatics-rg]
  name                = "webserver-user-assigned-id"
  resource_group_name = local.rg-name
  location            = local.rg-location
}

resource "azurerm_virtual_machine" "webserver" {
  count = var.number-of-vm[terraform.workspace]
  depends_on = [
    azurerm_role_assignment.vm-blob-contributor,
    null_resource.blob_upload
  ]
  name                          = "webserver${count.index + 1}"
  resource_group_name           = local.rg-name
  location                      = local.rg-location
  delete_os_disk_on_termination = var.delete-os-disk-on-termination
  vm_size                       = var.vm-size[terraform.workspace]
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
    custom_data = templatefile(
      "${path.module}/startup_script.tpl",
      {
        user_assigned_identity = azurerm_user_assigned_identity.webservers-userid.id,
        storage_account_name   = lower(local.storage_account_name),
        container_name         = var.container_name[0]
      }
    )
  }
  os_profile_linux_config {
    disable_password_authentication = var.disable-password-auth
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.webservers-userid.id]
  }
}
