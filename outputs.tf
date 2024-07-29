output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "nsg" {
  value = azurerm_network_security_group.nsg
}

output "subscriptionId" {
  value = data.azurerm_subscription.current.subscription_id
}
