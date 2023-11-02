output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "subnets" {
  value = azurerm_subnet.subnets
}

output "subscriptionId" {
  value = data.azurerm_subscription.current.subscription_id
}
