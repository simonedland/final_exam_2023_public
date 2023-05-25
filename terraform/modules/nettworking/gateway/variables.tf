variable "name" {
    type        = string
    description = "The name of the application gateway"
}
variable "resource_group_name" {
    type        = string
    description = "The name of the resource group in which to create the application gateway"
}
variable "location" {
    type        = string
    description = "The Azure Region in which to create the application gateway"
    default = "norwayeast"
}
variable "subnet_id" {
    type        = string
    description = "The ID of the subnet in which to create the application gateway"
}
variable "frontend_ip_name" {
    type        = string
    description = "The name of the public IP address to associate with the application gateway"
}
variable "public_ip_address_id" {
    type        = string
    description = "The ID of the public IP address to associate with the application gateway"
}
variable "frontend_port_name" {
    type        = string
    description = "The name of the frontend port to associate with the application gateway"
}
variable "https_frontend_port_name" {
    type        = string
    description = "The name of the HTTPS frontend port to associate with the application gateway"
}
variable "https_listener_name" {
    type        = string
    description = "The name of the listeners"
}
variable "listener_name" {
    type        = string
    description = "The name of the listeners"
}
variable "frontend_ip_configuration_name" {
    type        = string
    description = "The name of the frontend IP configuration"
}
variable "https_request_routing_rule_name" {
    type        = string
    description = "The name of the HTTPS request routing rule"
}
variable "request_routing_rule_name" {
    type        = string
    description = "The name of the HTTP request routing rule"
}
variable "home_backend_pool_name" {
    type        = string
    description = "The name of the home backend pool"
}
variable "http_setting_name" {
    type        = string
    description = "The name of the HTTP settings"
}
variable "cert_password" {
    type        = string
    description = "The password for the certificate"
}

variable "combined_config" {
    type = map(object({
        backend_pool_name = string
        fqdns = list(string)
        http_setting_name = string
        probe_name = string
        path_rule_name = string
        path_rule_paths = list(string)
    }))
}