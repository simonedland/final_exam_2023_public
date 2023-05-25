resource "azurerm_storage_account" "storage" {
  count = var.number_of_storage_accounts
  name                     = "${var.storage_account_name}${count.index}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = false
  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [ var.frontend_subnet_ids ]
    ip_rules = [ var.global_ip ]
  }
  # Configure the storage account to host a static website
  static_website {
    index_document = "index.html"
  }
}