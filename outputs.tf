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

output "network_security_rules" {
  description = "contains network security rule configuration"
  value       = azurerm_network_security_rule.rules
}

output "subnet_network_security_group_associations" {
  description = "contains subnet network security group association configuration"
  value       = azurerm_subnet_network_security_group_association.nsg_as
}

output "route_table" {
  description = "contains route table configuration"
  value       = azurerm_route_table.rt
}

output "routes" {
  description = "contains route configuration"
  value       = azurerm_route.routes
}

output "subnet_route_table_associations" {
  description = "contains subnet route table association configuration"
  value       = azurerm_subnet_route_table_association.rt_as
}

output "virtual_network_dns_servers" {
  description = "contains virtual network dns servers configuration"
  value       = azurerm_virtual_network_dns_servers.dns
}
