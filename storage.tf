module "globomatics_storage" {
  depends_on = [ azurerm_resource_group.globomatics-rg ]
  source = "./modules/storage-account"
  resource_group_name = var.resource-group-name
  resource_group_location = var.resource-group-location
  storage_account_name = local.storage_account_name
  container_names = var.container_name
  storage_account_tags = local.common-tags
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
  depends_on = [module.globomatics_storage]
  provisioner "local-exec" {
    command     = <<-EOT
      #!/bin/bash
      az storage blob upload-batch --account-name="${lower(local.storage_account_name)}" --destination="${var.container_name[0]}" --source="./web"
    EOT
    interpreter = ["bash", "-c"]
  }
}


resource "azurerm_role_assignment" "vm-blob-contributor" {
  depends_on = [
    azurerm_user_assigned_identity.webservers-userid,
    module.globomatics_storage
  ]
  scope                = "/subscriptions/${var.subscription-id}/resourceGroups/${local.rg-name}/providers/Microsoft.Storage/storageAccounts/${lower(local.storage_account_name)}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.webservers-userid.principal_id
}

