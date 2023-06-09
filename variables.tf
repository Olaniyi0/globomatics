variable "resource-group-location" {
  description = "The location of the resource group"
  type        = string
  default     = "westeurope"
}

variable "resource-group-name" {
  description = "The name of the resource group"
  type        = string
}

variable "network-address-space" {
  description = "Adress space of the virtual network"
  type        = map(string)
  default = {
    Development = "10.10.0.0/16",
    Production  = "10.0.0.0/16"
  }
}

variable "vpc-subnet-count" {
  description = "The number of subnet to be created"
  type        = map(number)
  default = {
    Development = 2
    Production  = 3
  }
}

variable "delete-os-disk-on-termination" {
  description = "To delete OS disk when the VM is terminated"
  type        = bool
  default     = true
}

variable "vm-size" {
  description = "The size of the virtual machine to use"
  type        = map(string)
  default = {
    Development = "Standard_DS1_v2",
    Production  = "Standard_DS1_v2"
  }
}

variable "computer-name" {
  description = "Name of your computer (hostname)"
  type        = string
}

variable "admin-username" {
  description = "username of the admin"
  type        = string
}

variable "admin_password" {
  description = "Password of the admin"
  type        = string
  sensitive   = true
}

variable "disable-password-auth" {
  description = "To disable the use of password for loging into the vm"
  type        = bool
  default     = false
}

variable "enviroment-name" {
  description = "Name of the enviroment we are working with"
  type        = string
}

variable "project-name" {
  description = "Name of the project we are working with"
  type        = string
}

variable "company-name" {
  description = "Name of the comapny we are working with"
  type        = string
}

variable "lb-availability-zone" {
  description = "Zones for load balancer to be deployed"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "vm-availability-zones" {
  description = "Zones for the VM to be deployed"
  type        = list(list(string))
  default     = [["1"], ["2"], ["3"]]
}

variable "storage-account-name" {
  description = "Name of the storage account"
  type        = string
  default     = "globomatic"
}

variable "container_name" {
  description = "Name of the storage account container"
  type        = list(string)
}

variable "subscription-id" {
  description = "ID of the subscription resources will be created in"
  type        = string
}

variable "number-of-vm" {
  description = "Number of VMs to be deployed"
  type        = map(number)
  default = {
    Development = 2,
    Production  = 3
  }
}