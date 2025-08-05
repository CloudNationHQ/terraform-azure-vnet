module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
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
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = module.naming.virtual_network.name
    address_space       = ["10.0.0.0/16"]
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    subnets = {
      sn1 = {
        address_prefixes = ["10.0.1.0/24"]
        shared = {
          network_security_group = "shd"
        }
      },
      sn2 = {
        address_prefixes = ["10.0.2.0/24"]
        shared = {
          network_security_group = "shd"
        }
      },
      sn3 = {
        address_prefixes = ["10.0.3.0/24"]
        network_security_group = {
          rules = {
            myhttps = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "10.151.1.0/24"
              destination_address_prefix = "*"
            }
          }
        }
      },
      sn4 = {
        address_prefixes = ["10.0.4.0/24"]
        network_security_group = {
          rules = {
            multirule = {
              priority          = 110
              direction         = "Inbound"
              access            = "Allow"
              protocol          = "Tcp"
              source_port_range = "*"
              destination_port_ranges = [
                "80",
                "443",
                "8080"
              ]
              source_address_prefixes = [
                "10.10.1.0/24",
                "10.20.1.0/24",
                "10.30.1.0/24"
              ]
              destination_address_prefixes = [
                "10.0.4.10",
                "10.0.4.11",
                "10.0.4.12"
              ]
            }
          }
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
