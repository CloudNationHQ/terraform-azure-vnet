This example highlights the existing_vnet usage.

## Usage

```hcl
module "vnet" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 5.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    cidr           = ["10.0.0.0/16"]
    subnets = {
      sn1 = {
        cidr = ["10.0.0.0/24"]
        nsg  = {}
      }
    }
  }
}

module "use_existing" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 5.0"

  naming            = local.naming
  use_existing_vnet = true # Use existing vnets

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    subnets = {
      sn2 = {
        cidr = ["10.0.1.0/24"]
        nsg  = {}
      }
      sn3 = {
        cidr = ["10.0.2.0/24"]
        nsg  = {}
      }
    }
  }
}

```