moved {
  from = azurerm_virtual_network.vnet["vnet"]
  to   = azurerm_virtual_network.this["this"]
}

moved {
  from = data.azurerm_virtual_network.existing["vnet"]
  to   = data.azurerm_virtual_network.this["this"]
}

moved {
  from = azurerm_virtual_network_dns_servers.dns["default"]
  to   = azurerm_virtual_network_dns_servers.this["this"]
}

moved {
  from = azurerm_subnet.subnets
  to   = azurerm_subnet.this
}

moved {
  from = azurerm_network_security_group.nsg
  to   = azurerm_network_security_group.this
}

moved {
  from = azurerm_network_security_rule.rules
  to   = azurerm_network_security_rule.this
}

moved {
  from = azurerm_subnet_network_security_group_association.nsg_as
  to   = azurerm_subnet_network_security_group_association.this
}

moved {
  from = azurerm_route_table.rt
  to   = azurerm_route_table.this
}

moved {
  from = azurerm_route.routes
  to   = azurerm_route.this
}

moved {
  from = azurerm_subnet_route_table_association.rt_as
  to   = azurerm_subnet_route_table_association.this
}
