This example highlights the utilization of service endpoints on subnets.

## Usage

```hcl
module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.18.0.0/16"]

    subnets = {
      demo = {
        cidr = ["10.18.3.0/24"]
        nsg  = {}
        endpoints = [
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
    }
  }
}
```
