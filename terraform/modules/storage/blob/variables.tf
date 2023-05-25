variable "number_of_storage_accounts" {
  description = "Number of storage accounts to add the blob to"
  type = number
  default = 5
}
variable "storage_account_name" {
  description = "Name of the storage account"
  type = string
  default = "myterraformstorage"
}
variable "name" {
  description = "Name of the blob"
  type = string
  default = "index.html"
}
variable "content_type" {
  description = "Content type of the blob"
  type = string
  default = "text/html"
}
variable "blob_source" {
  description = "Source of the blob"
  type = string
  default = "web_data/index.html"
}
variable "storage_container_name" {
  description = "Name of the storage container"
  type = string
  default = "$web"
}
variable "type" {
  description = "Type of the blob"
  type = string
  default = "Block"
}
