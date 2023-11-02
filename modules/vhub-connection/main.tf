# virtual hub
data "azurerm_virtual_hub" "vhub" {
  name                = var.virtual_hub.name
  resource_group_name = var.virtual_hub.resourcegroup
}

# connection
resource "azurerm_virtual_hub_connection" "vcon" {
  name                      = var.virtual_hub.connection
  virtual_hub_id            = data.azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = var.virtual_hub.vnet
  internet_security_enabled = try(var.virtual_hub.internet_security_enabled, true)
}
