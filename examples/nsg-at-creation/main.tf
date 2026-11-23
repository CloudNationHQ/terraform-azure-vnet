module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name
    address_space       = ["10.0.0.0/16"]
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    subnets = {
      # individual nsg, attached when the subnet is created
      sn1 = {
        address_prefixes = ["10.0.1.0/24"]
        network_security_group = {
          rules = {
            https = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "*"
              destination_address_prefix = "*"
            }
          }
        }
      },
      # shared nsg, attached when the subnet is created
      sn2 = {
        address_prefixes = ["10.0.2.0/24"]
        shared = {
          network_security_group = "shd"
        }
      },
      # bump the version to resend the nsg id after the nsg of this subnet changed
      sn3 = {
        address_prefixes                     = ["10.0.3.0/24"]
        network_security_group_id_wo_version = 2
        shared = {
          network_security_group = "shd"
        }
      }
    }

    network_security_groups = {
      shd = {
        rules = {
          allow_http = {
            priority                   = 100
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
