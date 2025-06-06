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
      location = "northeurope"
    }
  }
}

module "public_ip" {
  source  = "cloudnationhq/pip/azure"
  version = "~> 4.0"

  naming = local.naming

  configs = {
    pub1 = {
      location            = module.rg.groups.demo.location
      resource_group_name = module.rg.groups.demo.name
      zones               = ["1", "2", "3"]
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.18.0.0/16"]
    use_default_route   = true
    default_next_hop    = module.public_ip.configs.pub1.ip_address // e.g. a network virtual appliance

    use_direct_route = {
      sn1 = ["sn2"]
    }

    subnets = {
      sn1 = {
        address_prefixes = ["10.18.0.0/27"]
      },
      sn2 = {
        address_prefixes = ["10.18.0.32/27"]
      },
      sn3 = {
        address_prefixes = ["10.18.0.64/27"]
      },
    }
  }
}
