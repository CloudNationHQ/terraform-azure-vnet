data "azurerm_subscription" "current" {}

# virtual network
resource "azurerm_virtual_network" "vnet" {
  name                    = var.vnet.name
  resource_group_name     = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                = coalesce(lookup(var.vnet, "location", null), var.location)
  address_space           = var.vnet.cidr
  tags                    = try(var.vnet.tags, var.tags, null)
  edge_zone               = try(var.vnet.edge_zone, null)
  bgp_community           = try(var.vnet.bgp_community, null)
  flow_timeout_in_minutes = try(var.vnet.flow_timeout_in_minutes, null)

  # not available yet in all regions
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

# dns
resource "azurerm_virtual_network_dns_servers" "dns" {
  dns_servers        = try(var.vnet.dns_servers, [])
  virtual_network_id = azurerm_virtual_network.vnet.id
}

# subnets
resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in local.subnets : subnet.subnet_key => subnet
  }

  name                                          = each.value.subnet_name
  resource_group_name                           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  virtual_network_name                          = each.value.virtual_network_name
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
        actions = try(lookup(delegation.value, "actions", []), [])
      }
    }
  }
}

# nsg's
resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsg

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
    for subnet_key, details in local.nsg : subnet_key => {
      subnet_id = azurerm_subnet.subnets[subnet_key].id
      nsg_id    = azurerm_network_security_group.nsg[subnet_key].id
    }
  }

  subnet_id                 = each.value.subnet_id
  network_security_group_id = each.value.nsg_id

  depends_on = [time_sleep.wait_for_subnet]
}

# subnet creation is not consistent in some regions, so we need to wait for it to be ready
# https://github.com/CloudNationHQ/terraform-azure-vnet/issues/24
resource "time_sleep" "wait_for_subnet" {
  depends_on = [azurerm_subnet.subnets]

  create_duration = "1m"
}

# route tables
resource "azurerm_route_table" "rt" {
  for_each = {
    for k, v in local.route : k => v if v.route_table == null || length(v.routes) > 0
  }

  name                          = each.value.rt_name
  resource_group_name           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                      = each.value.location
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  tags                          = each.value.tags

  dynamic "route" {
    for_each = each.value.routes

    content {
      name                   = route.key
      address_prefix         = lookup(route.value, "address_prefix", null)
      next_hop_type          = lookup(route.value, "next_hop_type", null)
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
}

resource "azurerm_route_table" "shd_rt" {
  for_each = try(var.vnet.route_tables, {})

  name                          = try(each.value.name, "${var.naming.route_table}-${each.key}")
  resource_group_name           = coalesce(lookup(var.vnet, "resource_group", null), var.resource_group)
  location                      = coalesce(lookup(var.vnet, "location", null), var.location)
  disable_bgp_route_propagation = try(each.value.disable_bgp_route_propagation, false)
  tags                          = try(each.value.tags, var.tags, null)

  dynamic "route" {
    for_each = each.value.routes

    content {
      name                   = route.key
      address_prefix         = lookup(route.value, "address_prefix", null)
      next_hop_type          = lookup(route.value, "next_hop_type", null)
      next_hop_in_ip_address = lookup(route.value, "next_hop_in_ip_address", null)
    }
  }
}

resource "azurerm_subnet_route_table_association" "rt_as" {
  for_each = local.route

  subnet_id = azurerm_subnet.subnets[each.key].id

  route_table_id = each.value.shd_route_table != null ? (
    contains(keys(var.vnet.route_tables), each.value.shd_route_table) ?
    azurerm_route_table.shd_rt[each.value.shd_route_table].id :
    azurerm_route_table.rt[each.key].id
  ) : azurerm_route_table.rt[each.key].id
}
