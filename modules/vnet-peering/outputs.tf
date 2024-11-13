output "vnet_peering" {
  description = "contains vnet peering configuration"
  value       = merge(azurerm_virtual_network_peering.local_to_remote, azurerm_virtual_network_peering.remote_to_local)
}
