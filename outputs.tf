output "vnet" {
  description = "contains virtual network configuration"
  value       = (var.use_existing_vnet || try(var.vnet.use_existing_vnet, false)) ? data.azurerm_virtual_network.existing["vnet"] : azurerm_virtual_network.vnet["vnet"]
}

output "subnets" {
  description = "contains subnet configuration"
  value       = azurerm_subnet.subnets
}

output "network_security_group" {
  description = "contains network security group configuration"
  value       = azurerm_network_security_group.nsg
}
