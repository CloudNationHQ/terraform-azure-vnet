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
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 7.0"

  naming = local.naming

  vnet = {
    name           = module.naming.virtual_network.name
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    cidr           = ["10.0.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.0.1.0/24"]
        service_endpoints = [
          "Microsoft.Storage",
          "Microsoft.Sql"
        ]
      }
      sn2 = {
        cidr = ["10.0.2.0/24"]
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
        cidr = ["10.0.3.0/24"]
        route_table = {
          routes = {
            rt3 = {
              address_prefix = "storage"
              next_hop_type  = "Internet"
            }
          }
        }
      }
      sn4 = {
        cidr = ["10.0.4.0/24"]
        network_security_group = {
          rules = {
            myhttps = {
              name                       = "myhttps"
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefixes    = ["10.0.0.0/24", "11.0.0.0/24"]
              destination_address_prefix = "*"
            }
            allow_http = {
              name                       = "allow_http"
              priority                   = 200
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "80"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
            }
          }
        }
      }
    }
  }
}
