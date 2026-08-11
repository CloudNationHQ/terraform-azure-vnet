output "vnet" {
  description = "contains virtual network configuration"
  value       = (var.use_existing_vnet || coalesce(var.vnet.use_existing_vnet, false)) ? data.azurerm_virtual_network.this["this"] : azurerm_virtual_network.this["this"]
}

output "subnets" {
  description = "contains subnet configuration"
  value       = azurerm_subnet.this
}

output "network_security_group" {
  description = "contains network security group configuration"
  value       = azurerm_network_security_group.this
}

output "network_security_rules" {
  description = "contains network security rule configuration"
  value       = azurerm_network_security_rule.this
}

output "subnet_network_security_group_associations" {
  description = "contains subnet network security group association configuration"
  value       = azurerm_subnet_network_security_group_association.this
}

output "route_table" {
  description = "contains route table configuration"
  value       = azurerm_route_table.this
}

output "routes" {
  description = "contains route configuration"
  value       = azurerm_route.this
}

output "subnet_route_table_associations" {
  description = "contains subnet route table association configuration"
  value       = azurerm_subnet_route_table_association.this
}

output "virtual_network_dns_servers" {
  description = "contains virtual network dns servers configuration"
  value       = azurerm_virtual_network_dns_servers.this
}
