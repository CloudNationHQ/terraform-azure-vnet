# existing virtual network
data "azurerm_virtual_network" "existing" {
  for_each = lookup(var.vnet, "existing", null) != null ? { "vnet" = var.vnet.existing } : {}

  name                = each.value.name
  resource_group_name = try(each.value.resource_group, var.resource_group)
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
  for_each = lookup(var.vnet, "existing", null) != null ? {} : { "vnet" = var.vnet }

  resource_group_name = coalesce(var.vnet.resource_group, var.resource_group)
  location            = coalesce(var.vnet.location, var.location)
  name                = var.vnet.name
  address_space       = var.vnet.address_space

  edge_zone               = try(var.vnet.edge_zone, null)
  bgp_community           = try(var.vnet.bgp_community, null)
  flow_timeout_in_minutes = try(var.vnet.flow_timeout_in_minutes, null)

  dynamic "encryption" {
    for_each = lookup(var.vnet, "encryption", null) != null ? [lookup(var.vnet, "encryption", null)] : []
    content {
      enforcement = encryption.value.enforcement
    }
  }

  tags = try(var.vnet.tags, var.tags, {})

  lifecycle {
    ignore_changes = [subnet, dns_servers]
  }
}

# dns servers
resource "azurerm_virtual_network_dns_servers" "dns" {
  for_each = {
    for k, v in {
      "default" = lookup(var.vnet, "existing", null) != null ? try(var.vnet.existing.dns_servers, []) : try(var.vnet.dns_servers, [])
    } : k => v
    if length(v) > 0
  }

  virtual_network_id = lookup(var.vnet, "existing", null) != null ? data.azurerm_virtual_network.existing["vnet"].id : azurerm_virtual_network.vnet["vnet"].id
  dns_servers        = each.value
}

# subnets
resource "azurerm_subnet" "subnets" {
  for_each = lookup(lookup(var.vnet, "existing", {}), "subnets", lookup(var.vnet, "subnets", {}))

  name = try(
    each.value.name, join("-", [var.naming.subnet, each.key])
  )

  resource_group_name = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.resource_group : coalesce(
    var.vnet.resource_group,
    var.resource_group
  )

  virtual_network_name                          = lookup(var.vnet, "existing", null) != null ? data.azurerm_virtual_network.existing["vnet"].name : azurerm_virtual_network.vnet["vnet"].name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = try(each.value.service_endpoints, [])
  private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, false)
  private_endpoint_network_policies             = try(each.value.private_endpoint_network_policies, "Disabled")
  service_endpoint_policy_ids                   = try(each.value.service_endpoint_policy_ids, [])
  default_outbound_access_enabled               = try(each.value.default_outbound_access_enabled, null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegations", {})
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.name
        actions = lookup(delegation.value, "actions", [])
      }
    }
  }
}

# network security groups
resource "azurerm_network_security_group" "nsg" {
  for_each = merge(
    lookup(var.vnet, "existing", null) != null ? lookup(lookup(var.vnet, "existing", {}), "network_security_groups", {}) : lookup(var.vnet, "network_security_groups", {}),
    lookup(var.vnet, "existing", null) != null ? {
      for subnet_key, subnet in lookup(lookup(var.vnet, "existing", {}), "subnets", {}) : subnet_key => subnet.network_security_group
      if lookup(subnet, "network_security_group", null) != null
      } : {
      for subnet_key, subnet in lookup(var.vnet, "subnets", {}) : subnet_key => subnet.network_security_group
      if lookup(subnet, "network_security_group", null) != null
    }
  )

  name = try(
    each.value.name,
    "${var.naming.network_security_group}-${each.key}"
  )

  resource_group_name = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.resource_group : coalesce(
    var.vnet.resource_group,
    var.resource_group
  )

  location = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.location : coalesce(
    var.vnet.location,
    var.location
  )

  tags = try(var.vnet.tags, var.tags, {})

  lifecycle {
    ignore_changes = [security_rule]
  }
}

# security rules
resource "azurerm_network_security_rule" "rules" {
  for_each = merge({
    for pair in flatten([
      for nsg_key, nsg in lookup(lookup(var.vnet, "existing", {}), "network_security_groups", lookup(var.vnet, "network_security_groups", {})) :
      try([
        for rule_key, rule in lookup(nsg, "rules", {}) : {
          key = "${nsg_key}_${rule_key}"
          value = {
            nsg_name = azurerm_network_security_group.nsg[nsg_key].name
            rule     = rule
            rule_name = try(
              rule.name, join("-", [var.naming.network_security_group_rule, rule_key])
            )
          }
        }
      ], [])
    ]) : pair.key => pair.value
    }, {
    for pair in flatten([
      for subnet_key, subnet in lookup(lookup(var.vnet, "existing", {}), "subnets", lookup(var.vnet, "subnets", {})) :
      try([
        for rule_key, rule in lookup(lookup(subnet, "network_security_group", {}), "rules", {}) : {
          key = "${subnet_key}_${rule_key}"
          value = {
            nsg_name = azurerm_network_security_group.nsg[subnet_key].name
            rule     = rule
            rule_name = try(
              rule.name, join("-", [var.naming.network_security_group_rule, rule_key])
            )
          }
        }
      ], [])
    ]) : pair.key => pair.value
  })

  name                         = each.value.rule_name
  priority                     = each.value.rule.priority
  direction                    = each.value.rule.direction
  access                       = each.value.rule.access
  protocol                     = each.value.rule.protocol
  source_port_range            = try(each.value.rule.source_port_range, null)
  source_port_ranges           = try(each.value.rule.source_port_ranges, null)
  destination_port_range       = try(each.value.rule.destination_port_range, null)
  destination_port_ranges      = try(each.value.rule.destination_port_ranges, null)
  source_address_prefix        = try(each.value.rule.source_address_prefix, null)
  source_address_prefixes      = try(each.value.rule.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.rule.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.rule.destination_address_prefixes, null)
  description                  = try(each.value.rule.description, null)
  network_security_group_name  = each.value.nsg_name

  resource_group_name = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.resource_group : coalesce(
    var.vnet.resource_group,
    var.resource_group
  )
}

# nsg associations
resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  for_each = {
    for subnet_key, subnet in lookup(lookup(var.vnet, "existing", {}), "subnets", lookup(var.vnet, "subnets", {})) : subnet_key => subnet
    if lookup(lookup(subnet, "shared", {}), "network_security_group", null) != null || lookup(subnet, "network_security_group", null) != null
  }

  subnet_id = azurerm_subnet.subnets[each.key].id
  network_security_group_id = lookup(lookup(each.value, "shared", {}), "network_security_group", null) != null ? (
    azurerm_network_security_group.nsg[lookup(each.value.shared, "network_security_group")].id
  ) : azurerm_network_security_group.nsg[each.key].id

  depends_on = [
    azurerm_network_security_rule.rules
  ]
}

# route tables
resource "azurerm_route_table" "rt" {
  for_each = merge(
    lookup(lookup(var.vnet, "existing", {}), "route_tables", {}),
    lookup(var.vnet, "route_tables", {}),
    # subnet level route tables from existing virtual network
    {
      for subnet_key, subnet in lookup(lookup(var.vnet, "existing", {}), "subnets", {}) :
      subnet_key => subnet.route_table
      if lookup(subnet, "route_table", null) != null
    },

    # subnet level route tables from new virtual network
    {
      for subnet_key, subnet in lookup(var.vnet, "subnets", {}) :
      subnet_key => subnet.route_table
      if lookup(subnet, "route_table", null) != null
    }
  )

  name = try(
    each.value.name,
    "${var.naming.route_table}-${each.key}"
  )

  resource_group_name = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.resource_group : coalesce(
    var.vnet.resource_group,
    var.resource_group
  )

  location = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.location : coalesce(
    var.vnet.location,
    var.location
  )

  bgp_route_propagation_enabled = try(each.value.bgp_route_propagation_enabled, true)
  tags                          = try(var.vnet.tags, var.tags, {})

  lifecycle {
    ignore_changes = [route]
  }
}

# routes
resource "azurerm_route" "routes" {
  for_each = merge({
    for pair in flatten([
      for rt_key, rt in merge(
        lookup(lookup(var.vnet, "existing", {}), "route_tables", {}),
        lookup(var.vnet, "route_tables", {})
        ) : [
        for route_key, route in lookup(rt, "routes", {}) : {
          key = "${rt_key}_${route_key}"
          value = {
            route_table_name = azurerm_route_table.rt[rt_key].name
            route            = route
            route_name       = try(route.name, join("-", [try(var.naming.route, "rt"), route_key]))
          }
        }
      ]
    ]) : pair.key => pair.value
    },
    {
      for pair in flatten([
        for subnet_key, subnet in merge(
          lookup(lookup(var.vnet, "existing", {}), "subnets", {}),
          lookup(var.vnet, "subnets", {})
          ) : [
          for route_key, route in lookup(lookup(subnet, "route_table", {}), "routes", {}) : {
            key = "${subnet_key}_${route_key}"
            value = {
              route_table_name = azurerm_route_table.rt[subnet_key].name
              route            = route
              route_name       = try(route.name, join("-", [try(var.naming.route, "rt"), route_key]))
            }
          }
        ] if lookup(subnet, "route_table", null) != null
      ]) : pair.key => pair.value
    }
  )

  name                   = each.value.route_name
  route_table_name       = each.value.route_table_name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = try(each.value.route.next_hop_in_ip_address, null)

  resource_group_name = lookup(var.vnet, "existing", null) != null ? var.vnet.existing.resource_group : coalesce(
    var.vnet.resource_group,
    var.resource_group
  )
}

# route table associations
resource "azurerm_subnet_route_table_association" "rt_as" {
  for_each = {
    for k, v in lookup(lookup(var.vnet, "existing", {}), "subnets", lookup(var.vnet, "subnets", {})) : k => v
    if lookup(v, "route_table", null) != null || lookup(lookup(v, "shared", {}), "route_table", null) != null
  }

  subnet_id = azurerm_subnet.subnets[each.key].id
  route_table_id = lookup(lookup(each.value, "shared", {}), "route_table", null) != null ? (
    azurerm_route_table.rt[lookup(lookup(each.value, "shared", {}), "route_table")].id
  ) : azurerm_route_table.rt[each.key].id

  depends_on = [azurerm_route_table.rt]
}
