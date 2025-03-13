resource "azurerm_virtual_network_peering" "local_to_remote" {
  name                                   = try(var.vnet_peering.local.peering_name, "peer-${substr(var.vnet_peering.local.name, 0, 35)}-to-${substr(var.vnet_peering.remote.name, 0, 35)}")
  resource_group_name                    = var.vnet_peering.local.resource_group_name
  virtual_network_name                   = var.vnet_peering.local.name
  remote_virtual_network_id              = var.vnet_peering.remote.id
  allow_virtual_network_access           = try(var.vnet_peering.local.allow_virtual_network_access, true)
  allow_forwarded_traffic                = try(var.vnet_peering.local.allow_forwarded_traffic, false)
  allow_gateway_transit                  = try(var.vnet_peering.local.allow_gateway_transit, false)
  only_ipv6_peering_enabled              = try(var.vnet_peering.local.only_ipv6_peering_enabled, false)
  peer_complete_virtual_networks_enabled = try(var.vnet_peering.local.peer_complete_virtual_networks_enabled, true)
  local_subnet_names                     = try(var.vnet_peering.local.subnet_names, [])
  remote_subnet_names                    = try(var.vnet_peering.remote.subnet_names, [])
  use_remote_gateways                    = try(var.vnet_peering.local.use_remote_gateways, false)

  triggers = {
    remote_address_space = join(",", try(var.vnet_peering.remote.address_space, []))
  }
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  name                                   = try(var.vnet_peering.remote.peering_name, "peer-${substr(var.vnet_peering.remote.name, 0, 35)}-to-${substr(var.vnet_peering.local.name, 0, 35)}")
  resource_group_name                    = var.vnet_peering.remote.resource_group_name
  virtual_network_name                   = var.vnet_peering.remote.name
  remote_virtual_network_id              = var.vnet_peering.local.id
  allow_virtual_network_access           = try(var.vnet_peering.remote.allow_virtual_network_access, true)
  allow_forwarded_traffic                = try(var.vnet_peering.remote.allow_forwarded_traffic, false)
  allow_gateway_transit                  = try(var.vnet_peering.remote.allow_gateway_transit, false)
  only_ipv6_peering_enabled              = try(var.vnet_peering.remote.only_ipv6_peering_enabled, false)
  peer_complete_virtual_networks_enabled = try(var.vnet_peering.remote.peer_complete_virtual_networks_enabled, true)
  local_subnet_names                     = try(var.vnet_peering.remote.subnet_names, [])
  remote_subnet_names                    = try(var.vnet_peering.local.subnet_names, [])
  use_remote_gateways                    = try(var.vnet_peering.remote.use_remote_gateways, false)

  triggers = {
    remote_address_space = join(",", try(var.vnet_peering.local.address_space, []))
  }
  provider = azurerm.remote
}
