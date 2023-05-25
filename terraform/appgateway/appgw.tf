# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Declare a variable for certificate password
variable "cert_password" {
  type = string
}

# Define local variables to be used throughout the configuration
locals {
  home_probe_name                = "home-probe"
  resource_group_name            = "rg-appgw-prod-norwayeast-001"
  location                       = "norwayeast"
  public_ip_name                 = "pip-appgw-prod-norwayeast-001"

  #use looping to define the backend pools
  bicep_pool = [for i in range(0, 5) : "simonsbicepdeploymentsa${i}.z1.web.core.windows.net"]
  terraform_pool = [for i in range(0, 5) : "myterraformstorage${i}.z1.web.core.windows.net"]
  pulumi_pool = [for i in range(0, 5) : "simonspulumistorage${i}.z1.web.core.windows.net"]
  home_pool = [for i in range(0, 5) : "simonslandingpagestg${i}.z1.web.core.windows.net"]
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-appgw-prod-norwayeast-001"
  resource_group_name = local.resource_group_name
  location            = local.location
  address_space       = ["10.254.0.0/16"]
  depends_on = [
    azurerm_resource_group.rg
  ]
}

# Create frontend subnet
resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# Create backend subnet
resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.254.2.0/24"]
}

# Public IP address for the Application Gateway
resource "azurerm_public_ip" "pip" {  
  name                = local.public_ip_name
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Dynamic"
  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "appgw" {
  source = "../modules/nettworking/gateway"
  name = "appgw-prod-norwayeast-001"
  location = "norwayeast"
  resource_group_name = local.resource_group_name
  subnet_id = azurerm_subnet.frontend.id
  frontend_ip_name = local.public_ip_name
  public_ip_address_id = azurerm_public_ip.pip.id
  frontend_port_name = "frontend-port"
  https_frontend_port_name = "https-frontend-port"
  https_listener_name = "https-listener"
  listener_name = "http-listener"
  frontend_ip_configuration_name = "frontend-ip"
  https_request_routing_rule_name = "https-rule"
  request_routing_rule_name = "http-rule"
  home_backend_pool_name = "home-backend-pool"
  http_setting_name = "home"
  cert_password = var.cert_password
  
  combined_config = {
    "bicep" = {
      backend_pool_name = "bicep-backend-pool"
      fqdns = local.bicep_pool
      http_setting_name = "bicep"
      path_rule_name = "bicep-path-rule"
      path_rule_paths = ["/bicep/*"]
      probe_name = "bicep-probe"
    }
    "terraform" = {
      backend_pool_name = "terraform-backend-pool"
      fqdns = local.terraform_pool
      http_setting_name = "terraform"
      path_rule_name = "terraform-path-rule"
      path_rule_paths = ["/terraform/*"]
      probe_name = "terraform-probe"
    }
    "pulumi" = {
      backend_pool_name = "pulumi-backend-pool"
      fqdns = local.pulumi_pool
      http_setting_name = "pulumi"
      path_rule_name = "pulumi-path-rule"
      path_rule_paths = ["/pulumi/*"]
      probe_name = "pulumi-probe"
    }
    "home" = {
      backend_pool_name = "home-backend-pool"
      fqdns = local.home_pool
      http_setting_name = "home"
      path_rule_name = "home-path-rule"
      path_rule_paths = ["/home/*"]
      probe_name = "home-probe"
    }
  }
}