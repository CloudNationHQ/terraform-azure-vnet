locals {
  subnets = flatten([
    for subnet_key, subnet in try(var.vnet.subnets, {}) : {
      subnet_key                 = subnet_key
      virtual_network_name       = azurerm_virtual_network.vnet.name
      address_prefixes           = subnet.cidr
      endpoints                  = try(subnet.endpoints, [])
      enforce_priv_link_service  = try(subnet.enforce_priv_link_service, false)
      enforce_priv_link_endpoint = try(subnet.enforce_priv_link_endpoint, false)
      delegations                = try(subnet.delegations, [])
      rules                      = try(subnet.rules, {})
      subnet_name                = try(subnet.name, join("-", [var.naming.subnet, subnet_key]))
      nsg_name                   = try(subnet.nsg.name, join("-", [var.naming.network_security_group, subnet_key]))
      rt_name                    = try(subnet.route.name, join("-", [var.naming.route_table, subnet_key]), {})
      location                   = var.vnet.location
      routes                     = try(subnet.route.routes, {})
      route_table                = try(subnet.route, null)
      shd_route_table            = try(subnet.route_table, null)
    }
  ])
}
