data "azurerm_subscription" "current" {}

# existing virtual network
data "azurerm_virtual_network" "existing" {
  for_each = var.use_existing_vnet ? {
    (var.vnet.name) = var.vnet
  } : {}

  name                = var.vnet.name
  resource_group_name = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
  for_each = var.use_existing_vnet ? {} : {
    (var.vnet.name) = var.vnet
  }

  name                    = var.vnet.name
  resource_group_name     = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                = coalesce(lookup(var.vnet, "location", null), var.location)
  address_space           = var.vnet.cidr
  tags                    = try(var.vnet.tags, var.tags, null)
  edge_zone               = try(var.vnet.edge_zone, null)
  bgp_community           = try(var.vnet.bgp_community, null)
  flow_timeout_in_minutes = try(var.vnet.flow_timeout_in_minutes, null)

  dynamic "encryption" {
    for_each = try(var.vnet.encryption_mode, null) != null ? { "default" = var.vnet.encryption_mode } : {}

    content {
      enforcement = try(var.vnet.encryption_mode, "AllowUnencrypted")
    }
  }
  lifecycle {
    ignore_changes = [subnet, dns_servers]
  }
}

resource "azurerm_virtual_network_dns_servers" "dns" {
  for_each = var.use_existing_vnet ? {} : {
    (var.vnet.name) = var.vnet
  }

  dns_servers        = try(var.vnet.dns_servers, [])
  virtual_network_id = azurerm_virtual_network.vnet[each.key].id
}

# subnets
resource "azurerm_subnet" "subnets" {
  for_each = length(lookup(var.vnet, "subnets", {})) > 0 ? {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {

      subnet_key                                    = subnet_key
      virtual_network_name                          = var.vnet.name
      address_prefixes                              = subnet.cidr
      endpoints                                     = try(subnet.endpoints, [])
      private_link_service_network_policies_enabled = try(subnet.private_link_service_network_policies_enabled, false)
      private_endpoint_network_policies             = try(subnet.private_endpoint_network_policies, "Disabled")
      default_outbound_access_enabled               = try(subnet.default_outbound_access_enabled, null)
      service_endpoint_policy_ids                   = try(subnet.service_endpoint_policy_ids, null)
      subnet_name                                   = try(subnet.name, join("-", [var.naming.subnet, subnet_key]))
      tags                                          = try(subnet.nsg.tags, var.tags, null)
      delegations = [for key, del in try(subnet.delegations, {}) : {
        delegation_key = key
        name           = del.name
        actions        = try(del.actions, [])
      }]
    }
  } : {}

  name                                          = each.value.subnet_name
  resource_group_name                           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  virtual_network_name                          = var.use_existing_vnet ? data.azurerm_virtual_network.existing[var.vnet.name].name : azurerm_virtual_network.vnet[var.vnet.name].name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.endpoints
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  default_outbound_access_enabled               = each.value.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = delegation.value.delegation_key

      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

# network security groups
resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => {
      nsg_name = try(subnet.nsg.name, join("-", [var.naming.network_security_group, subnet_key]))
      rules    = values(lookup(lookup(subnet, "nsg", {}), "rules", {}))
      tags     = try(subnet.nsg.tags, var.tags, null)
      location = coalesce(lookup(var.vnet, "location", null), var.location)
    }
    if lookup(subnet, "nsg", null) != null
  }

  name                = each.value.nsg_name
  resource_group_name = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location            = each.value.location
  tags                = each.value.tags

  dynamic "security_rule" {
    for_each = each.value.rules

    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      description                  = lookup(security_rule.value, "description", null)
      source_port_range            = lookup(security_rule.value, "source_port_range", null)
      source_port_ranges           = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_range       = lookup(security_rule.value, "destination_port_range", null)
      destination_port_ranges      = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefix        = lookup(security_rule.value, "source_address_prefix", null)
      source_address_prefixes      = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefix   = lookup(security_rule.value, "destination_address_prefix", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  for_each = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => subnet
    if lookup(subnet, "nsg", null) != null
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [time_sleep.wait_for_subnet]
}

resource "time_sleep" "wait_for_subnet" {
  depends_on = [azurerm_subnet.subnets]

  create_duration = "1m"
}

# shared route tables
resource "azurerm_route_table" "shd_rt" {
  for_each = try(var.vnet.route_tables, {})

  name                          = try(each.value.name, "${var.naming.route_table}-${each.key}")
  resource_group_name           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                      = coalesce(lookup(var.vnet, "location", null), var.location)
  bgp_route_propagation_enabled = try(each.value.bgp_route_propagation_enabled, true)
  tags                          = try(each.value.tags, var.tags, null)

  lifecycle {
    ignore_changes = [route]
  }
}

resource "azurerm_route" "shared_routes" {
  for_each = {
    for route_item in flatten([
      for rt_key, rt in lookup(var.vnet, "route_tables", {}) : [
        for route_key, route_value in try(rt.routes, {}) : {

          key           = "${rt_key}_${route_key}"
          route_table   = azurerm_route_table.shd_rt[rt_key]
          route_name    = route_key
          route_details = route_value
        }
      ]
    ]) : route_item.key => route_item
  }

  name                   = each.value.route_name
  resource_group_name    = each.value.route_table.resource_group_name
  route_table_name       = each.value.route_table.name
  address_prefix         = each.value.route_details.address_prefix
  next_hop_type          = each.value.route_details.next_hop_type
  next_hop_in_ip_address = lookup(each.value.route_details, "next_hop_in_ip_address", null)
}

# individual route tables
resource "azurerm_route_table" "rt" {
  for_each = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => subnet
    if lookup(subnet, "route_table", null) != null
  }

  name                          = try(each.value.route_table.name, "${var.naming.route_table}-${each.key}")
  resource_group_name           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                      = coalesce(lookup(var.vnet, "location", null), var.location)
  bgp_route_propagation_enabled = try(each.value.route_table.bgp_route_propagation_enabled, true)
  tags                          = try(each.value.route_table.tags, var.tags, null)

  lifecycle {
    ignore_changes = [route]
  }
}

resource "azurerm_route" "routes" {
  for_each = {
    for route_item in flatten([
      for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : [
        for route_key, route_value in try(subnet.route_table.routes, {}) : {

          key         = "${subnet_key}_${route_key}"
          route_table = azurerm_route_table.rt[subnet_key]
          route_name  = route_key
          route       = route_value
        }
      ]
    ]) : route_item.key => route_item
  }

  name                   = each.value.route_name
  resource_group_name    = each.value.route_table.resource_group_name
  route_table_name       = each.value.route_table.name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = lookup(each.value.route, "next_hop_in_ip_address", null)
}

resource "azurerm_subnet_route_table_association" "rt_as" {
  for_each = {
    for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => subnet
    if lookup(subnet, "route_table_shared", null) != null || lookup(subnet, "route_table", null) != null
  }

  subnet_id      = azurerm_subnet.subnets[each.key].id
  route_table_id = lookup(each.value, "route_table_shared", null) != null ? azurerm_route_table.shd_rt[each.value.route_table_shared].id : azurerm_route_table.rt[each.key].id
}
