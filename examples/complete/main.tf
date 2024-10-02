module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 5.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    cidr           = ["10.18.0.0/16"]

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
