locals {
  nsg_rules = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key =>
    values(lookup(lookup(subnet, "nsg", {}), "rules", {}))
  }

  route_table_info = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {
      route_table     = lookup(subnet, "route", {})
      shd_route_table = try(subnet.route_table, null)
    }
  }

  subnets = length(lookup(var.vnet, "subnets", {})) > 0 ? flatten([
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : {
      subnet_key                 = subnet_key
      virtual_network_name       = azurerm_virtual_network.vnet.name
      address_prefixes           = subnet.cidr
      endpoints                  = try(subnet.endpoints, [])
      enforce_priv_link_service  = try(subnet.enforce_priv_link_service, false)
      enforce_priv_link_endpoint = try(subnet.enforce_priv_link_endpoint, false)
      rules                      = local.nsg_rules[subnet_key]
      subnet_name                = try(subnet.name, join("-", [var.naming.subnet, subnet_key]))
      nsg_name                   = try(subnet.nsg.name, join("-", [var.naming.network_security_group, subnet_key]))
      rt_name                    = try(subnet.route.name, join("-", [var.naming.route_table, subnet_key]), {})
      location                   = var.vnet.location
      routes                     = try(subnet.route.routes, {})
      route_table                = local.route_table_info[subnet_key].route_table
      shd_route_table            = local.route_table_info[subnet_key].shd_route_table

      delegations = [for d in try(subnet.delegations, {}) : {
        name    = d.name
        actions = try(d.actions, [])
      }]
    }
  ]) : []
}
