module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "northeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 4.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    cidr           = ["10.18.0.0/16"]

    subnets = {
      sn1 = {
        cidr        = ["10.18.1.0/24"]
        route_table = "shd"
        nsg         = {}
      },
      sn2 = {
        cidr        = ["10.18.2.0/24"]
        route_table = "shd"
        nsg         = {}
      },
      sn3 = {
        cidr = ["10.18.3.0/24"]
        nsg  = {}
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
