output "vnet" {
  description = "contains virtual network configuration"
  value       = lookup(var.vnet, "existing", null) != null ? data.azurerm_virtual_network.existing["vnet"] : azurerm_virtual_network.vnet["vnet"]
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "network_security_group" {
  value = azurerm_network_security_group.nsg
}
