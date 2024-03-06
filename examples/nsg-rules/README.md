This example highlights using network security groups in a subnet.

## Usage: nsg rules

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.4"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    cidr          = ["10.18.0.0/16"]
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    subnets = {
      sn1 = {
        cidr = ["10.18.1.0/24"]
        nsg = {
          rules = local.rules
        }
      }
    }
  }
}
```

The local variable defined below holds all the rules.

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
      destination_port_range     = "3306"
      source_address_prefix      = "10.0.0.0/24"
      destination_address_prefix = "*"
    }
  }
}
```
