resource "azurerm_storage_account" "globomatics-storage-account" {
  name                     = var.storage-account-name
  resource_group_name      = local.rg-name
  location                 = local.rg-location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = local.common-tags
}

resource "azurerm_storage_container" "web-resources" {
  depends_on            = [azurerm_storage_account.globomatics-storage-account]
  name                  = local.container-name
  storage_account_name  = var.storage-account-name
  container_access_type = "private"
}

# resource "azurerm_storage_blob" "web-files" {
#   depends_on             = [azurerm_storage_container.web-resources]
#   name                   = "web-files"
#   storage_account_name   = var.storage-account-name
#   storage_container_name = local.container-name
#   type                   = "Block"
#   source                 = "./web/*"
# }

resource "null_resource" "blob_upload" {
  depends_on = [ azurerm_storage_container.web-resources ]
  provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      az storage blob upload-batch --account-name="${var.storage-account-name}" --destination="${local.container-name}" --source="./web"
    EOT
    interpreter = ["bash", "-c"]
  }
}


resource "azurerm_role_assignment" "vm1-blob-contributor" {
  depends_on           = [
    azurerm_user_assigned_identity.webservers-userid,
    azurerm_storage_account.globomatics-storage-account
  ]
  scope                = "/subscriptions/${var.subscription-id}/resourceGroups/${local.rg-name}/providers/Microsoft.Storage/storageAccounts/${var.storage-account-name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.webservers-userid.principal_id
}

resource "azurerm_role_assignment" "vm2-blob-contributor" {
  depends_on           = [
    azurerm_user_assigned_identity.webservers-userid,
    azurerm_storage_account.globomatics-storage-account
  ]
  scope                = "/subscriptions/${var.subscription-id}/resourceGroups/${local.rg-name}/providers/Microsoft.Storage/storageAccounts/${var.storage-account-name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.webservers-userid.principal_id
}