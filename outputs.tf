output "vnet" {
  value = merge(azurerm_virtual_network.vnet, data.azurerm_virtual_network.existing)
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "network_security_group" {
  value = azurerm_network_security_group.nsg
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}
