# wrapper used by nsg_unknown_values.tftest.hcl: feeds the module nsg rules whose values
# are only known after apply, e.g. a public ip address created in the same deployment (#219)
resource "terraform_data" "pip" {
  input = "pip"
}

module "vnet" {
  source = "../../.."

  location            = "westeurope"
  resource_group_name = "rg-test"

  vnet = {
    name          = "vnet-test"
    address_space = ["10.0.0.0/16"]

    network_security_groups = {
      shared = {
        rules = {
          https = {
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefix      = "*"
            destination_address_prefix = terraform_data.pip.id
          }
        }
      }
    }

    subnets = {
      sub_a = {
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
              destination_address_prefix = terraform_data.pip.id
            }
          }
        }
      }
      sub_b = {
        address_prefixes = ["10.0.2.0/24"]
      }
    }
  }
}

output "rule_keys" {
  value = keys(module.vnet.network_security_rules)
}
