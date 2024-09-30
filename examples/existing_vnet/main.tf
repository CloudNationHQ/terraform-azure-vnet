module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd", "jptest"]
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

module "vnet" {
  # source  = "cloudnationhq/vnet/azure"
  # version = "~> 4.0"
  source = "../../"

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
  # source  = "cloudnationhq/vnet/azure"
  # version = "~> 4.0"
  source = "../../"

  naming            = local.naming
  use_existing_vnet = true

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
