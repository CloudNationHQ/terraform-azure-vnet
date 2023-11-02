This example illustrates the default virtual network setup, in its simplest form. It lays out a foundational network structure, guaranteeing protected and contained communication within its scope.

## Usage: simple

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]
  }
}
```

## Usage: multiple

Additionally, for certain scenarios, the example below highlights the ability to use multiple virtual networks, enabling a broader network setup.

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

  for_each = local.vnets

  naming = local.naming
  vnet   = each.value
}
```

The module uses a local to iterate, generating a virtual network for each key.

```hcl
locals {
  vnets = {
    vnet1 = {
      name          = join("-", [module.naming.virtual_network.name, "001"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
      cidr          = ["10.18.0.0/16"]

      subnets = {
        sql = {
          cidr = ["10.18.1.0/24"]
          endpoints = [
            "Microsoft.Sql"
          ]
        },
        ws = {
          cidr = ["10.18.2.0/24"]
          delegations = {
            databricks = {
              name = "Microsoft.Databricks/workspaces"
            }
          }
        }
      }
    },
    vnet2 = {
      name          = join("-", [module.naming.virtual_network.name, "002"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
      cidr          = ["10.20.0.0/16"]

      subnets = {
        plink = {
          cidr = ["10.20.1.0/24"]
          endpoints = [
            "Microsoft.Storage",
          ]
        }
      }
    }
  }
}
```

The below maps resource types to their corresponding outputs from the naming module, ensuring consistent naming conventions across resources

```hcl
locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["subnet", "network_security_group"]
}
```
