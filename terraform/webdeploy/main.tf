# Declare local variables for resource group name, storage account name, and location
locals {
    resource_group_name = "rg-terraform-prod-norwayeast-001"
    storage_account_name = "myterraformstorage"
    location = "norwayeast"
}

# Configure the Azure provider with the features
provider "azurerm" {
  features {}
}

# Declare variables for the global IP address and frontend subnet IDs
variable "global_ip" {
    description = "Variables for the page"
}
variable "frontend_subnet_ids" {
  description = "values for the frontend subnet ids"
}

variable "number_of_storage_accounts" {
    default = 5
  description = "number of storage accounts"
}
# Create a resource group with the specified name and location
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

module "storage_account" {
  source = "../modules/storage/storage_account"
  resource_group_name = azurerm_resource_group.rg.name
  location = local.location
  storage_account_name = local.storage_account_name
  number_of_storage_accounts = var.number_of_storage_accounts
  global_ip = var.global_ip
  frontend_subnet_ids = var.frontend_subnet_ids
}

module "storage_blob" {
  count = var.number_of_storage_accounts
  source = "../modules/storage/blob"
  storage_account_name = module.storage_account.sa_output[count.index].name
  blob_source = "web_data/index.html"
}

module "storage_blob1" {
  count = var.number_of_storage_accounts
  name = "terraform-logo.svg"
  source = "../modules/storage/blob"
  content_type = "image/svg+xml"
  storage_account_name = module.storage_account.sa_output[count.index].name
  blob_source = "web_data/terraform-logo.svg"
}
