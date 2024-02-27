This example shows the use of delegations on subnets.

## Usage

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.3"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.18.1.0/24"]
        delegations = {
          sql = {
            name = "Microsoft.Sql/managedInstances"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
              "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
              "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
            ]
          }
        }
      }
      sn2 = {
        cidr = ["10.18.2.0/24"]
        delegations = {
          web = { name = "Microsoft.Web/serverFarms" }
        }
      }
    }
  }
}
```
