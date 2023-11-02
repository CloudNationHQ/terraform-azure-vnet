module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "dev"]
}

module "rg" {
  source = "github.com/cloudnationhq/az-cn-module-tf-rg"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 0.1"

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
      },
      sn3 = {
        cidr = ["10.18.3.0/24"]
        route = {
          routes = {
            rt3 = {
              address_prefix = "storage"
              next_hop_type  = "Internet"
            }
          }
        }
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
