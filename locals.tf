locals {
  nsg_rules = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key =>
    values(lookup(lookup(subnet, "nsg", {}), "rules", {}))
  }
}

locals {
  nsg = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {

      nsg_name = try(subnet.nsg.name, join("-", [var.naming.network_security_group, subnet_key]))
      rules    = local.nsg_rules[subnet_key]
      tags     = try(subnet.nsg.tags, {})
      location = var.vnet.location
    }
    if lookup(subnet, "nsg", null) != null
  }
}

locals {
  route = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {
      rt_name         = try(subnet.route.name, join("-", [var.naming.route_table, subnet_key]))
      routes          = try(subnet.route.routes, {})
      tags            = try(subnet.route.tags, {})
      location        = var.vnet.location
      route_table     = try(lookup(subnet, "route", {}), {})
      shd_route_table = try(subnet.route_table, null)
    }
    if lookup(subnet, "route", null) != null || lookup(subnet, "route_table", null) != null
  }
}

locals {
  subnets = length(lookup(var.vnet, "subnets", {})) > 0 ? flatten([
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : {
      subnet_key                  = subnet_key
      virtual_network_name        = azurerm_virtual_network.vnet.name
      address_prefixes            = subnet.cidr
      endpoints                   = try(subnet.endpoints, [])
      enforce_priv_link_service   = try(subnet.enforce_priv_link_service, false)
      enforce_priv_link_endpoint  = try(subnet.enforce_priv_link_endpoint, false)
      service_endpoint_policy_ids = try(subnet.service_endpoint_policy_ids, null)
      subnet_name                 = try(subnet.name, join("-", [var.naming.subnet, subnet_key]))
      location                    = var.vnet.location
      tags                        = try(subnet.nsg.tags, {})
      delegations = [for d in try(subnet.delegations, {}) : {
        name    = d.name
        actions = try(d.actions, [])
      }]
    }
  ]) : []
}
