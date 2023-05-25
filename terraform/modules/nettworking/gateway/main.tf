resource "azurerm_application_gateway" "network" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # SKU configuration for the Application Gateway
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 1
  }
  
  # Gateway IP configuration
  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  # Frontend IP configuration
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.public_ip_address_id
  }

  dynamic "backend_address_pool" {
    for_each = var.combined_config
    content {
      name  = backend_address_pool.value.backend_pool_name
      fqdns = backend_address_pool.value.fqdns
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.combined_config
    content {
      name                                = backend_http_settings.value.http_setting_name
      probe_name                          = backend_http_settings.value.probe_name
      pick_host_name_from_backend_address = true
      cookie_based_affinity               = "Disabled"
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = 30
      path                                = "/"
    }
  }
  
  # Probes for health checking of the backend pools
  # Probe for the bicep backend pool
  dynamic "probe" {
    for_each = var.combined_config
    content {
      name                                      = probe.value["probe_name"]
      protocol                                  = "Http"
      path                                      = "/"
      interval                                  = 10
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
    }
  }
  
  # Frontend port for HTTP traffic
  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  # Frontend port for HTTPS traffic
  frontend_port {
    name = var.https_frontend_port_name
    port = 443
  }

  # SSL certificate for HTTPS traffic
  ssl_certificate {
    name = "ssl-certificate"
    data = filebase64("newcert.pfx")
    password = var.cert_password
  }

  # HTTP listener for HTTPS traffic
  http_listener {
    name                           = var.https_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.https_frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-certificate"
  }

  # HTTP listener for HTTP traffic
  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

 # Redirect configuration for redirecting HTTP traffic to HTTPS
 redirect_configuration {
    name = "redirect-configuration"
    redirect_type = "Permanent"
    target_listener_name = var.https_listener_name
    include_path = true
    include_query_string = true
  }

  # Request routing rule for HTTPS traffic
  request_routing_rule {
    name               = var.https_request_routing_rule_name
    rule_type          = "PathBasedRouting"
    http_listener_name = var.https_listener_name
    url_path_map_name  = "url-path-map"
  }

  # Request routing rule for HTTP traffic to redirect to HTTPS
  request_routing_rule {
    name               = var.request_routing_rule_name
    rule_type          = "Basic"
    http_listener_name = var.listener_name
    redirect_configuration_name = "redirect-configuration"
    
  }

  # URL path map to route traffic based on URL paths
  url_path_map {
    name                               = "url-path-map"
    default_backend_address_pool_name  = var.home_backend_pool_name
    default_backend_http_settings_name = var.http_setting_name
    
    # Path rule for routing traffic with /bicep/* path to the bicep backend pool
    dynamic "path_rule" {
      for_each = var.combined_config
      content {
        name                       = path_rule.value.path_rule_name
        paths                      = path_rule.value.path_rule_paths
        backend_address_pool_name  = path_rule.value.backend_pool_name
        backend_http_settings_name = path_rule.value.http_setting_name
      }
    }
  }
}
