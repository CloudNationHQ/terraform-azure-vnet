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
      tags     = try(subnet.nsg.tags, var.tags, null)
      location = coalesce(lookup(var.vnet, "location", null), var.location)
    }
    if lookup(subnet, "nsg", null) != null
  }
}

locals {
  route = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {
      rt_name                       = try(subnet.route.name, join("-", [var.naming.route_table, subnet_key]))
      routes                        = try(subnet.route.routes, {})
      tags                          = try(subnet.route.tags, var.tags, null)
      location                      = coalesce(lookup(var.vnet, "location", null), var.location)
      route_table                   = try(lookup(subnet, "route", {}), {})
      shd_route_table               = try(subnet.route_table, null)
      bgp_route_propagation_enabled = try(subnet.route.bgp_route_propagation_enabled, true)
    }
    if lookup(subnet, "route", null) != null || lookup(subnet, "route_table", null) != null
  }
}

locals {
  subnets = length(lookup(var.vnet, "subnets", {})) > 0 ? flatten([
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : {
      subnet_key                                    = subnet_key
      virtual_network_name                          = azurerm_virtual_network.vnet.name
      address_prefixes                              = subnet.cidr
      endpoints                                     = try(subnet.endpoints, [])
      private_link_service_network_policies_enabled = try(subnet.private_link_service_network_policies_enabled, false)
      private_endpoint_network_policies             = try(subnet.private_endpoint_network_policies, null)
      default_outbound_access_enabled               = try(subnet.default_outbound_access_enabled, null)
      service_endpoint_policy_ids                   = try(subnet.service_endpoint_policy_ids, null)
      subnet_name                                   = try(subnet.name, join("-", [var.naming.subnet, subnet_key]))
      location                                      = coalesce(lookup(var.vnet, "location", null), var.location)
      tags                                          = try(subnet.nsg.tags, var.tags, null)

      delegations = [for key, del in try(subnet.delegations, {}) : {
        delegation_key = key
        name           = del.name
        actions        = try(del.actions, [])
      }]
    }
  ]) : []
}
