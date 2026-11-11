mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/mock"
    }
  }
}

variables {
  location            = "westeurope"
  resource_group_name = "rg-test"
}

run "network_identifier_is_set_for_mapped_service" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      subnets = {
        sub_a = {
          address_prefixes  = ["10.0.1.0/24"]
          service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
          service_endpoint_network_identifiers = {
            "Microsoft.Storage" = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityPerimeters/nsp"
          }
        }
      }
    }
  }

  assert {
    condition = alltrue([
      for se in azurerm_subnet.this["sub_a"].service_endpoint :
      se.network_identifier == (se.service == "Microsoft.Storage" ? "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityPerimeters/nsp" : null)
    ])
    error_message = "only Microsoft.Storage should carry a network_identifier, other services must stay null"
  }
}

run "mistyped_identifier_key_fails" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      subnets = {
        sub_a = {
          address_prefixes  = ["10.0.1.0/24"]
          service_endpoints = ["Microsoft.Storage"]
          service_endpoint_network_identifiers = {
            "Microsoft.storage" = "id"
          }
        }
      }
    }
  }

  expect_failures = [var.vnet]
}

run "identifiers_without_endpoints_fail" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      subnets = {
        sub_a = {
          address_prefixes = ["10.0.1.0/24"]
          service_endpoint_network_identifiers = {
            "Microsoft.Storage" = "id"
          }
        }
      }
    }
  }

  expect_failures = [var.vnet]
}
