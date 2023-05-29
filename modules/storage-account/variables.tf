variable "storage_account_name" {
  description = "A unique name for the storage account"
  type        = string
}

variable "container_names" {
  description = "Name(s) of the container(s) to create"
  type        = list(string)
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "Location of the resource group"
  type        = string
}

variable "account_tier" {
  description = "Tier of the storage account"
  type        = string
  default     = "Standard"
}

variable "storage_account_tags" {
  description = "Tags to be associated with the storage account"
  type        = map(string)
}

variable "container_access_type" {
  description = "Access type of the container"
  type        = string
  default     = "private"
}
