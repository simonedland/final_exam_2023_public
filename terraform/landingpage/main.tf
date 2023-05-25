# Declare local variables for resource group name, storage account name, and location
locals {
    resource_group_name = "rg-landingpage-prod-norwayeast-001"
    storage_account_name = "simonslandingpagestg"
    location = "norwayeast"
    number_of_storage_accounts = 5
}

# Configure the Azure provider with the features
provider "azurerm" {
  features {}
}

# Declare variables for the global IP address and frontend subnet IDs
variable "global_ip" {
    description = "Variables for the landing page"
}
variable "frontend_subnet_ids" {
  description = "values for the frontend subnet ids"
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
    number_of_storage_accounts = local.number_of_storage_accounts
    global_ip = var.global_ip
    frontend_subnet_ids = var.frontend_subnet_ids
}

module "blob" {
    count = local.number_of_storage_accounts
    source = "../modules/storage/blob"
    storage_account_name = module.storage_account.sa_output[count.index].name
    blob_source = "web_data/index.html"
}