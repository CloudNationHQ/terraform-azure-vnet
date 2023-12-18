locals {
  subnets = flatten([
    for subnet_key, subnet in var.vnet.subnets : {
      subnet_key           = subnet_key
      virtual_network_name = azurerm_virtual_network.vnet.name
      address_prefixes     = subnet.cidr
      rules                = subnet.nsg.rules
      subnet_name          = join("-", [var.naming.subnet, subnet_key])
      nsg_name             = join("-", [var.naming.network_security_group, subnet_key])
      location             = var.vnet.location
    }
  ])
}
