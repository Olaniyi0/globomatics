resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = var.account_tier
  account_replication_type = "GRS"
  tags                     = var.storage_account_tags
}

resource "azurerm_storage_container" "container" {
  depends_on = [ azurerm_storage_account.storage_account ]
  for_each              = toset(var.container_names)
  name                  = each.value
  storage_account_name  = lower(var.storage_account_name)
  container_access_type = var.container_access_type
}

