mock_provider "azurerm" {
  mock_data "azurerm_virtual_network" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vnet/providers/Microsoft.Network/virtualNetworks/vnet-existing"
    }
  }
}

variables {
  location            = "westeurope"
  resource_group_name = "rg-fallback"
}

run "existing_vnet_via_global_flag" {
  command = plan

  variables {
    use_existing_vnet = true

    vnet = {
      name                = "vnet-app"
      resource_group_name = "rg-vnet"
      dns_servers         = ["10.0.0.4"]
      subnets = {
        sub_a = { address_prefixes = ["10.0.1.0/24"] }
      }
    }
  }

  assert {
    condition = length(data.azurerm_virtual_network.this) == 1 && length(azurerm_virtual_network.this) == 0
    error_message = format(
      "the global flag must select the data source, got %d data source instance(s) and %d managed vnet(s)",
      length(data.azurerm_virtual_network.this),
      length(azurerm_virtual_network.this),
    )
  }

  assert {
    condition = data.azurerm_virtual_network.this["this"].resource_group_name == "rg-vnet"
    error_message = format(
      "existing vnet must be looked up in vnet.resource_group_name (\"rg-vnet\"), got %q - %s",
      data.azurerm_virtual_network.this["this"].resource_group_name,
      data.azurerm_virtual_network.this["this"].resource_group_name == "rg-fallback" ? "the coalesce fell through to var.resource_group_name" : "unexpected resource group",
    )
  }

  assert {
    condition = azurerm_virtual_network_dns_servers.this["this"].virtual_network_id == data.azurerm_virtual_network.this["this"].id
    error_message = format(
      "dns servers must attach to the existing vnet id, got %q",
      azurerm_virtual_network_dns_servers.this["this"].virtual_network_id,
    )
  }

  assert {
    condition = azurerm_subnet.this["sub_a"].virtual_network_name == data.azurerm_virtual_network.this["this"].name
    error_message = format(
      "subnet must be created in the existing vnet, got %q",
      azurerm_subnet.this["sub_a"].virtual_network_name,
    )
  }

  assert {
    condition = output.vnet.id == data.azurerm_virtual_network.this["this"].id
    error_message = format(
      "output \"vnet\" must expose the existing vnet id, got %q",
      output.vnet.id,
    )
  }
}

run "existing_vnet_via_object_flag" {
  command = plan

  variables {
    use_existing_vnet = false

    vnet = {
      name                = "vnet-app"
      resource_group_name = "rg-vnet"
      use_existing_vnet   = true
      dns_servers         = ["10.0.0.4"]
      subnets = {
        sub_a = { address_prefixes = ["10.0.1.0/24"] }
      }
    }
  }

  assert {
    condition = length(data.azurerm_virtual_network.this) == 1 && length(azurerm_virtual_network.this) == 0
    error_message = format(
      "vnet.use_existing_vnet alone must select the data source, got %d data source instance(s) and %d managed vnet(s)",
      length(data.azurerm_virtual_network.this),
      length(azurerm_virtual_network.this),
    )
  }

  assert {
    condition = azurerm_virtual_network_dns_servers.this["this"].virtual_network_id == data.azurerm_virtual_network.this["this"].id
    error_message = format(
      "dns servers must attach to the existing vnet id, got %q",
      azurerm_virtual_network_dns_servers.this["this"].virtual_network_id,
    )
  }

  assert {
    condition = output.vnet.id == data.azurerm_virtual_network.this["this"].id
    error_message = format(
      "output \"vnet\" must expose the existing vnet id, got %q",
      output.vnet.id,
    )
  }
}

run "global_flag_overrides_object_false" {
  command = plan

  variables {
    use_existing_vnet = true

    vnet = {
      name                = "vnet-app"
      resource_group_name = "rg-vnet"
      use_existing_vnet   = false
      dns_servers         = ["10.0.0.4"]
      subnets = {
        sub_a = { address_prefixes = ["10.0.1.0/24"] }
      }
    }
  }

  assert {
    condition = length(data.azurerm_virtual_network.this) == 1 && length(azurerm_virtual_network.this) == 0
    error_message = format(
      "the global flag must override vnet.use_existing_vnet = false, got %d data source instance(s) and %d managed vnet(s)",
      length(data.azurerm_virtual_network.this),
      length(azurerm_virtual_network.this),
    )
  }

  assert {
    condition = output.vnet.id == data.azurerm_virtual_network.this["this"].id
    error_message = format(
      "output \"vnet\" must expose the existing vnet id, got %q",
      output.vnet.id,
    )
  }
}

run "managed_vnet_when_neither_flag_set" {
  command = apply

  override_resource {
    target = azurerm_virtual_network.this["this"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-vnet/providers/Microsoft.Network/virtualNetworks/vnet-managed"
    }
  }

  variables {
    use_existing_vnet = false

    vnet = {
      name                = "vnet-app"
      resource_group_name = "rg-vnet"
      address_space       = ["10.0.0.0/16"]
      dns_servers         = ["10.0.0.4"]
      subnets = {
        sub_a = { address_prefixes = ["10.0.1.0/24"] }
      }
    }
  }

  assert {
    condition = length(data.azurerm_virtual_network.this) == 0 && length(azurerm_virtual_network.this) == 1
    error_message = format(
      "with neither flag set the vnet must be created and nothing looked up, got %d data source instance(s) and %d managed vnet(s)",
      length(data.azurerm_virtual_network.this),
      length(azurerm_virtual_network.this),
    )
  }

  assert {
    condition = azurerm_virtual_network_dns_servers.this["this"].virtual_network_id == azurerm_virtual_network.this["this"].id
    error_message = format(
      "dns servers must attach to the created vnet id, got %q",
      azurerm_virtual_network_dns_servers.this["this"].virtual_network_id,
    )
  }

  assert {
    condition = azurerm_subnet.this["sub_a"].virtual_network_name == azurerm_virtual_network.this["this"].name
    error_message = format(
      "subnet must be created in the created vnet, got %q",
      azurerm_subnet.this["sub_a"].virtual_network_name,
    )
  }

  assert {
    condition = output.vnet.id == azurerm_virtual_network.this["this"].id
    error_message = format(
      "output \"vnet\" must expose the created vnet id, got %q",
      output.vnet.id,
    )
  }
}
