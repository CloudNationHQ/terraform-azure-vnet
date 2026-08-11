mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/mock"
    }
  }
  mock_resource "azurerm_network_security_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/mock"
    }
  }
  mock_resource "azurerm_route_table" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/mock"
    }
  }
}

variables {
  location            = "westeurope"
  resource_group_name = "rg-test"
}

run "individual_nsg_and_route_table_per_subnet" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      subnets = {
        sub_a = {
          address_prefixes = ["10.0.1.0/24"]
          network_security_group = {
            rules = {
              allow_https = {
                priority                   = 100
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_range     = "443"
                source_address_prefix      = "*"
                destination_address_prefix = "*"
              }
            }
          }
          route_table = {
            routes = {
              to_hub = {
                address_prefix = "10.10.0.0/16"
                next_hop_type  = "VnetLocal"
              }
            }
          }
        }
        sub_b = {
          address_prefixes = ["10.0.2.0/24"]
          network_security_group = {
            rules = {
              deny_all = {
                priority                   = 200
                direction                  = "Inbound"
                access                     = "Deny"
                protocol                   = "*"
                source_port_range          = "*"
                destination_port_range     = "*"
                source_address_prefix      = "*"
                destination_address_prefix = "*"
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition = toset(keys(azurerm_network_security_group.this)) == toset(["sub_a", "sub_b"])
    error_message = format(
      "inline subnet NSGs must be keyed by subnet key, expected [sub_a, sub_b], got %s",
      jsonencode(sort(keys(azurerm_network_security_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_route_table.this)) == toset(["sub_a"])
    error_message = format(
      "only sub_a declares a route table, expected [sub_a], got %s",
      jsonencode(sort(keys(azurerm_route_table.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_network_security_rule.this)) == toset(["sub_a_allow_https", "sub_b_deny_all"])
    error_message = format(
      "subnet rules must be keyed <subnet>_<rule>, expected [sub_a_allow_https, sub_b_deny_all], got %s",
      jsonencode(sort(keys(azurerm_network_security_rule.this))),
    )
  }

  assert {
    condition = alltrue([
      azurerm_network_security_rule.this["sub_a_allow_https"].network_security_group_name == azurerm_network_security_group.this["sub_a"].name,
      azurerm_network_security_rule.this["sub_b_deny_all"].network_security_group_name == azurerm_network_security_group.this["sub_b"].name,
    ])
    error_message = format(
      "subnet rules must attach to their own subnet's NSG, got sub_a_allow_https => %q, sub_b_deny_all => %q",
      azurerm_network_security_rule.this["sub_a_allow_https"].network_security_group_name,
      azurerm_network_security_rule.this["sub_b_deny_all"].network_security_group_name,
    )
  }

  assert {
    condition = toset(keys(azurerm_route.this)) == toset(["sub_a_to_hub"])
    error_message = format(
      "subnet routes must be keyed <subnet>_<route>, expected [sub_a_to_hub], got %s",
      jsonencode(sort(keys(azurerm_route.this))),
    )
  }

  assert {
    condition = azurerm_route.this["sub_a_to_hub"].route_table_name == azurerm_route_table.this["sub_a"].name
    error_message = format(
      "subnet route must attach to its own subnet's route table, got %q",
      azurerm_route.this["sub_a_to_hub"].route_table_name,
    )
  }

  assert {
    condition = toset(keys(azurerm_subnet_network_security_group_association.this)) == toset(["sub_a", "sub_b"])
    error_message = format(
      "every subnet with an inline NSG must be associated, expected [sub_a, sub_b], got %s",
      jsonencode(sort(keys(azurerm_subnet_network_security_group_association.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_subnet_route_table_association.this)) == toset(["sub_a"])
    error_message = format(
      "only sub_a has a route table, expected associations [sub_a], got %s",
      jsonencode(sort(keys(azurerm_subnet_route_table_association.this))),
    )
  }
}

run "shared_nsg_and_route_table_referenced_by_subnets" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      network_security_groups = {
        shared_nsg = {
          rules = {
            allow_https = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
            }
          }
        }
      }

      route_tables = {
        shared_rt = {
          routes = {
            to_hub = {
              address_prefix = "10.10.0.0/16"
              next_hop_type  = "VnetLocal"
            }
          }
        }
      }

      subnets = {
        sub_a = {
          address_prefixes = ["10.0.1.0/24"]
          shared = {
            network_security_group = "shared_nsg"
            route_table            = "shared_rt"
          }
        }
        sub_b = {
          address_prefixes = ["10.0.2.0/24"]
          shared = {
            network_security_group = "shared_nsg"
            route_table            = "shared_rt"
          }
        }
      }
    }
  }

  assert {
    condition = toset(keys(azurerm_network_security_group.this)) == toset(["shared_nsg"])
    error_message = format(
      "a shared NSG must exist exactly once and not be duplicated per subnet, expected [shared_nsg], got %s",
      jsonencode(sort(keys(azurerm_network_security_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_route_table.this)) == toset(["shared_rt"])
    error_message = format(
      "a shared route table must exist exactly once, expected [shared_rt], got %s",
      jsonencode(sort(keys(azurerm_route_table.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_network_security_rule.this)) == toset(["shared_nsg_allow_https"])
    error_message = format(
      "shared NSG rules must be keyed <nsg>_<rule>, expected [shared_nsg_allow_https], got %s",
      jsonencode(sort(keys(azurerm_network_security_rule.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_route.this)) == toset(["shared_rt_to_hub"])
    error_message = format(
      "shared route table routes must be keyed <table>_<route>, expected [shared_rt_to_hub], got %s",
      jsonencode(sort(keys(azurerm_route.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_subnet_network_security_group_association.this)) == toset(["sub_a", "sub_b"])
    error_message = format(
      "subnets referencing a shared NSG must still be associated, expected [sub_a, sub_b], got %s",
      jsonencode(sort(keys(azurerm_subnet_network_security_group_association.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_subnet_route_table_association.this)) == toset(["sub_a", "sub_b"])
    error_message = format(
      "subnets referencing a shared route table must still be associated, expected [sub_a, sub_b], got %s",
      jsonencode(sort(keys(azurerm_subnet_route_table_association.this))),
    )
  }
}

run "mixed_shared_and_individual" {
  command = apply

  override_resource {
    target = azurerm_network_security_group.this["shared_nsg"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-shared"
    }
  }
  override_resource {
    target = azurerm_network_security_group.this["sub_b"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkSecurityGroups/nsg-sub-b"
    }
  }
  override_resource {
    target = azurerm_route_table.this["shared_rt"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/rt-shared"
    }
  }
  override_resource {
    target = azurerm_route_table.this["sub_b"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/routeTables/rt-sub-b"
    }
  }

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      network_security_groups = {
        shared_nsg = {
          rules = {
            allow_https = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
            }
          }
        }
      }

      route_tables = {
        shared_rt = {
          routes = {
            to_hub = {
              address_prefix = "10.10.0.0/16"
              next_hop_type  = "VnetLocal"
            }
          }
        }
      }

      subnets = {
        sub_a = {
          address_prefixes = ["10.0.1.0/24"]
          shared = {
            network_security_group = "shared_nsg"
            route_table            = "shared_rt"
          }
        }
        sub_b = {
          address_prefixes = ["10.0.2.0/24"]
          network_security_group = {
            rules = {
              deny_all = {
                priority                   = 200
                direction                  = "Inbound"
                access                     = "Deny"
                protocol                   = "*"
                source_port_range          = "*"
                destination_port_range     = "*"
                source_address_prefix      = "*"
                destination_address_prefix = "*"
              }
            }
          }
          route_table = {
            routes = {
              to_fw = {
                address_prefix = "10.20.0.0/16"
                next_hop_type  = "VnetLocal"
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition = toset(keys(azurerm_network_security_group.this)) == toset(["shared_nsg", "sub_b"])
    error_message = format(
      "NSG map must merge shared and inline sources, expected [shared_nsg, sub_b], got %s",
      jsonencode(sort(keys(azurerm_network_security_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_route_table.this)) == toset(["shared_rt", "sub_b"])
    error_message = format(
      "route table map must merge shared and inline sources, expected [shared_rt, sub_b], got %s",
      jsonencode(sort(keys(azurerm_route_table.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_network_security_rule.this)) == toset(["shared_nsg_allow_https", "sub_b_deny_all"])
    error_message = format(
      "rules must merge <nsg>_<rule> and <subnet>_<rule> keyings, expected [shared_nsg_allow_https, sub_b_deny_all], got %s",
      jsonencode(sort(keys(azurerm_network_security_rule.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_route.this)) == toset(["shared_rt_to_hub", "sub_b_to_fw"])
    error_message = format(
      "routes must merge <table>_<route> and <subnet>_<route> keyings, expected [shared_rt_to_hub, sub_b_to_fw], got %s",
      jsonencode(sort(keys(azurerm_route.this))),
    )
  }

  assert {
    condition = alltrue([
      azurerm_network_security_rule.this["shared_nsg_allow_https"].network_security_group_name == azurerm_network_security_group.this["shared_nsg"].name,
      azurerm_network_security_rule.this["sub_b_deny_all"].network_security_group_name == azurerm_network_security_group.this["sub_b"].name,
    ])
    error_message = format(
      "rules must attach to the NSG of their own source, got shared_nsg_allow_https => %q, sub_b_deny_all => %q",
      azurerm_network_security_rule.this["shared_nsg_allow_https"].network_security_group_name,
      azurerm_network_security_rule.this["sub_b_deny_all"].network_security_group_name,
    )
  }

  assert {
    condition = alltrue([
      azurerm_route.this["shared_rt_to_hub"].route_table_name == azurerm_route_table.this["shared_rt"].name,
      azurerm_route.this["sub_b_to_fw"].route_table_name == azurerm_route_table.this["sub_b"].name,
    ])
    error_message = format(
      "routes must attach to the table of their own source, got shared_rt_to_hub => %q, sub_b_to_fw => %q",
      azurerm_route.this["shared_rt_to_hub"].route_table_name,
      azurerm_route.this["sub_b_to_fw"].route_table_name,
    )
  }

  assert {
    condition = alltrue([
      azurerm_subnet_network_security_group_association.this["sub_a"].network_security_group_id == azurerm_network_security_group.this["shared_nsg"].id,
      azurerm_subnet_network_security_group_association.this["sub_b"].network_security_group_id == azurerm_network_security_group.this["sub_b"].id,
    ])
    error_message = format(
      "shared and inline subnets must resolve to different NSGs, got sub_a => %q, sub_b => %q",
      azurerm_subnet_network_security_group_association.this["sub_a"].network_security_group_id,
      azurerm_subnet_network_security_group_association.this["sub_b"].network_security_group_id,
    )
  }

  assert {
    condition = alltrue([
      azurerm_subnet_route_table_association.this["sub_a"].route_table_id == azurerm_route_table.this["shared_rt"].id,
      azurerm_subnet_route_table_association.this["sub_b"].route_table_id == azurerm_route_table.this["sub_b"].id,
    ])
    error_message = format(
      "shared and inline subnets must resolve to different route tables, got sub_a => %q, sub_b => %q",
      azurerm_subnet_route_table_association.this["sub_a"].route_table_id,
      azurerm_subnet_route_table_association.this["sub_b"].route_table_id,
    )
  }
}

run "subnet_with_neither_is_not_associated" {
  command = plan

  variables {
    vnet = {
      name          = "vnet-test"
      address_space = ["10.0.0.0/16"]

      subnets = {
        sub_a = {
          address_prefixes = ["10.0.1.0/24"]
          network_security_group = {
            rules = {
              allow_https = {
                priority                   = 100
                direction                  = "Inbound"
                access                     = "Allow"
                protocol                   = "Tcp"
                source_port_range          = "*"
                destination_port_range     = "443"
                source_address_prefix      = "*"
                destination_address_prefix = "*"
              }
            }
          }
        }
        bare = {
          address_prefixes = ["10.0.2.0/24"]
        }
      }
    }
  }

  assert {
    condition = toset(keys(azurerm_network_security_group.this)) == toset(["sub_a"])
    error_message = format(
      "a bare subnet must not get an NSG, expected [sub_a], got %s",
      jsonencode(sort(keys(azurerm_network_security_group.this))),
    )
  }

  assert {
    condition = toset(keys(azurerm_subnet_network_security_group_association.this)) == toset(["sub_a"])
    error_message = format(
      "a subnet with neither inline nor shared NSG must not be associated, expected [sub_a], got %s",
      jsonencode(sort(keys(azurerm_subnet_network_security_group_association.this))),
    )
  }

  assert {
    condition = length(azurerm_subnet_route_table_association.this) == 0
    error_message = format(
      "no subnet declares or shares a route table, so there must be no route table associations, got %s",
      jsonencode(sort(keys(azurerm_subnet_route_table_association.this))),
    )
  }
}
