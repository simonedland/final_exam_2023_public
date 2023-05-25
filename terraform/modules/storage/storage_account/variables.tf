variable "number_of_storage_accounts" {
  description = "The number of storage accounts to create"
  type        = number
  default     = 5
}
variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "storage"
}
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg"
}
variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "norwayeast"
}
variable "frontend_subnet_ids" {
  description = "values for the frontend subnet ids"
  type        = string
  default     = ""
}
variable "global_ip" {
  description = "Variables for the page"
  type        = string
  default     = ""
}