This example underscores the implementation of routes within subnets.

## Usage

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 1.3"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.18.1.0/24"]
        routes = {
          rt1 = {
            address_prefix = "Storage"
            next_hop_type  = "Internet"
          }
        }
      }
    }
  }
}
```

In situations where several subnets should share the same route table, the following configuration can be employed:

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 1.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr        = ["10.18.1.0/24"]
        route_table = "shd"
      },
      sn2 = {
        cidr        = ["10.18.2.0/24"]
        route_table = "shd"
      }
    }

    route_tables = {
      shd = {
        routes = {
          rt1 = { address_prefix = "0.0.0.0/0", next_hop_type = "Internet" }
        }
      }
    }
  }
}
```
