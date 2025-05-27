# existing virtual network
data "azurerm_virtual_network" "existing" {
  for_each = var.use_existing_vnet || try(
    var.vnet.use_existing_vnet, false
  ) ? { "vnet" = var.vnet } : {}

  name = each.value.name

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )
}

# virtual network
resource "azurerm_virtual_network" "vnet" {
  for_each = var.use_existing_vnet || try(
    var.vnet.use_existing_vnet, false
  ) ? {} : { "vnet" = var.vnet }

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.vnet, "location", null
    ), var.location
  )

  name                           = var.vnet.name
  address_space                  = var.vnet.address_space
  edge_zone                      = var.vnet.edge_zone
  bgp_community                  = var.vnet.bgp_community
  flow_timeout_in_minutes        = var.vnet.flow_timeout_in_minutes
  private_endpoint_vnet_policies = var.vnet.private_endpoint_vnet_policies

  dynamic "ddos_protection_plan" {
    for_each = try(var.vnet.ddos_protection_plan, null) != null ? [var.vnet.ddos_protection_plan] : []

    content {
      id     = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }

  dynamic "encryption" {
    for_each = try(var.vnet.encryption, null) != null ? [var.vnet.encryption] : []

    content {
      enforcement = encryption.value.enforcement
    }
  }

  tags = coalesce(
    var.vnet.tags, var.tags
  )

  lifecycle {
    ignore_changes = [subnet, dns_servers]
  }
}

# dns servers
resource "azurerm_virtual_network_dns_servers" "dns" {
  for_each = {
    for k, v in {
      "default" = try(
        var.vnet.dns_servers, []
      )
    } : k => v
    if length(v) > 0
  }

  virtual_network_id = (var.use_existing_vnet ||
    try(
      var.vnet.use_existing_vnet, false
    )
  ) ? data.azurerm_virtual_network.existing["vnet"].id : azurerm_virtual_network.vnet["vnet"].id

  dns_servers = each.value
}

# subnets
resource "azurerm_subnet" "subnets" {
  for_each = try(var.vnet.subnets, {})

  name = coalesce(
    each.value.name, try(
      join("-", [var.naming.subnet, each.key]), null
    ), each.key
  )

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )

  virtual_network_name = (var.use_existing_vnet
    || try(
      var.vnet.use_existing_vnet, false
    )
  ) ? data.azurerm_virtual_network.existing["vnet"].name : azurerm_virtual_network.vnet["vnet"].name

  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  private_endpoint_network_policies             = each.value.private_endpoint_network_policies
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  default_outbound_access_enabled               = each.value.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = lookup(
      each.value, "delegations", {}
    )

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

# network security groups
resource "azurerm_network_security_group" "nsg" {
  for_each = merge(
    # Handle top-level shared NSGs
    try(
      var.vnet.network_security_groups, {}
    ),
    # Handle subnet NSGs
    {
      for subnet_key, subnet in try(var.vnet.subnets, {}) : subnet_key => lookup(subnet, "network_security_group", null)
      if lookup(subnet, "network_security_group", null) != null
    }
  )

  name = coalesce(
    lookup(each.value, "name", null),
    try("${var.naming.network_security_group}-${each.key}", null)
  )

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.vnet, "location", null
    ), var.location
  )

  tags = coalesce(
    var.vnet.tags, var.tags
  )

  lifecycle {
    ignore_changes = [security_rule]
  }
}

# security rules
resource "azurerm_network_security_rule" "rules" {
  for_each = merge({
    for pair in flatten([
      for nsg_key, nsg in try(var.vnet.network_security_groups, {}) :
      try([
        for rule_key, rule in lookup(nsg, "rules", {}) : {
          key = "${nsg_key}_${rule_key}"
          value = {
            nsg_name = azurerm_network_security_group.nsg[nsg_key].name
            rule     = rule
            rule_name = coalesce(
              rule.name, join("-", [var.naming.network_security_group_rule, rule_key])
            )
          }
        }
      ], [])
    ]) : pair.key => pair.value
    }, {
    for pair in flatten([
      for subnet_key, subnet in try(var.vnet.subnets, {}) :
      try([
        for rule_key, rule in lookup(lookup(subnet, "network_security_group", {}), "rules", {}) : {
          key = "${subnet_key}_${rule_key}"
          value = {
            nsg_name = azurerm_network_security_group.nsg[subnet_key].name
            rule     = rule
            rule_name = coalesce(
              rule.name, join("-", [var.naming.network_security_group_rule, rule_key])
            )
          }
        }
      ], [])
    ]) : pair.key => pair.value
  })

  name                                       = each.value.rule_name
  priority                                   = each.value.rule.priority
  direction                                  = each.value.rule.direction
  access                                     = each.value.rule.access
  protocol                                   = each.value.rule.protocol
  source_port_range                          = each.value.rule.source_port_range
  source_port_ranges                         = each.value.rule.source_port_ranges
  destination_port_range                     = each.value.rule.destination_port_range
  destination_port_ranges                    = each.value.rule.destination_port_ranges
  source_address_prefix                      = each.value.rule.source_address_prefix
  source_address_prefixes                    = each.value.rule.source_address_prefixes
  destination_address_prefix                 = each.value.rule.destination_address_prefix
  destination_address_prefixes               = each.value.rule.destination_address_prefixes
  description                                = each.value.rule.description
  network_security_group_name                = each.value.nsg_name
  source_application_security_group_ids      = each.value.rule.source_application_security_group_ids
  destination_application_security_group_ids = each.value.rule.destination_application_security_group_ids

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )
}

# nsg associations
resource "azurerm_subnet_network_security_group_association" "nsg_as" {
  for_each = {
    for subnet_key, subnet in try(var.vnet.subnets, {}) : subnet_key => subnet
    if lookup(
      lookup(subnet, "shared", {}
    ), "network_security_group", null) != null || lookup(subnet, "network_security_group", null) != null
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
    try(var.vnet.route_tables, {}),
    # subnet level route tables
    {
      for subnet_key, subnet in try(var.vnet.subnets, {}) :
      subnet_key => subnet.route_table
      if lookup(subnet, "route_table", null) != null
    }
  )

  name = coalesce(
    each.value.name, try(
      join("-", [var.naming.route_table, each.key]), null
    ), each.key
  )

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.vnet, "location", null
    ), var.location
  )

  tags = coalesce(
    var.vnet.tags, var.tags
  )

  bgp_route_propagation_enabled = try(each.value.bgp_route_propagation_enabled, true)

  lifecycle {
    ignore_changes = [route]
  }
}

# routes
resource "azurerm_route" "routes" {
  for_each = merge({
    for pair in flatten([
      for rt_key, rt in try(var.vnet.route_tables, {}) : [
        for route_key, route in lookup(rt, "routes", {}) : {
          key = "${rt_key}_${route_key}"
          value = {
            route_table_name = azurerm_route_table.rt[rt_key].name
            route            = route
            route_name = coalesce(
              route.name, join("-", [try(var.naming.route, "rt"), route_key]
              )
            )
          }
        }
      ]
    ]) : pair.key => pair.value
    },
    {
      for pair in flatten([
        for subnet_key, subnet in try(var.vnet.subnets, {}) : [
          for route_key, route in lookup(lookup(subnet, "route_table", {}), "routes", {}) : {
            key = "${subnet_key}_${route_key}"
            value = {
              route_table_name = azurerm_route_table.rt[subnet_key].name
              route            = route
              route_name = coalesce(
                route.name, join("-", [try(var.naming.route, "rt"), route_key]
                )
              )
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
  next_hop_in_ip_address = each.value.route.next_hop_in_ip_address

  resource_group_name = coalesce(
    lookup(
      var.vnet, "resource_group_name", null
    ), var.resource_group_name
  )
}

# route table associations
resource "azurerm_subnet_route_table_association" "rt_as" {
  for_each = {
    for k, v in try(var.vnet.subnets, {}) : k => v
    if lookup(v, "route_table", null) != null || lookup(lookup(v, "shared", {}), "route_table", null) != null
  }

  subnet_id = azurerm_subnet.subnets[each.key].id
  route_table_id = lookup(lookup(each.value, "shared", {}), "route_table", null) != null ? (
    azurerm_route_table.rt[lookup(lookup(each.value, "shared", {}), "route_table")].id
  ) : azurerm_route_table.rt[each.key].id

  depends_on = [azurerm_route_table.rt]
}
