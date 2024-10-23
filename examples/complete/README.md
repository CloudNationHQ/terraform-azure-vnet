This example highlights the complete usage.

## Usage

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 7.0"

  naming = local.naming
  vnet   = local.vnet
}
```

The module uses the below locals for configuration:

```hcl
locals {
  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.18.1.0/24"]
        nsg  = {}
        endpoints = [
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
      sn2 = {
        cidr = ["10.18.2.0/24"]
        nsg  = {}
        delegations = {
          databricks = {
            name = "Microsoft.Databricks/workspaces"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
              "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
              "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
            ]
          }
        }
      }
      sn3 = {
        cidr = ["10.18.3.0/24"]
        routes = {
          udr1 = {
            address_prefix = "Storage"
            next_hop_type  = "Internet"
          }
        }
      }
      sn4 = {
        cidr = ["10.18.4.0/24"]
        nsg = {
          rules = local.rules
        }
      }
    }
  }
}
```

```hcl
locals {
  rules = {
    myhttps = {
      name                       = "myhttps"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.151.1.0/24"
      destination_address_prefix = "*"
    }
    mysql = {
      name                       = "mysql"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["3306", "3307"]
      source_address_prefixes    = ["10.0.0.0/24", "11.0.0.0/24"]
      destination_address_prefix = "*"
    }
  }
}
```
