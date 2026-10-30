variable "location" {
  description = "Azure Region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

variable "admin_username" {
  description = "VM User"
  type        = string
}

variable "vm_size" {
  description = "VM Size"
  type        = string
}
