output "vnet" {
  value = var.use_existing_vnet ? try(data.azurerm_virtual_network.existing["vnet"], null) : try(azurerm_virtual_network.vnet["vnet"], null)
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