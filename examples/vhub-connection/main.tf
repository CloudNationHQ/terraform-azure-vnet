module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 1.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    cidr          = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        cidr = ["10.19.1.0/24"]
      }
    }
  }
}

module "vhub-connection" {
  source  = "cloudnationhq/vnet/azure//modules/vhub-connection"
  version = "~> 1.0"

  providers = {
    azurerm = azurerm.connectivity
  }

  virtual_hub = {
    name          = "vhub-westeurope"
    resourcegroup = "rg-vwan-shared"
    connection    = module.naming.virtual_hub_connection.name
    vnet          = module.network.vnet.id
  }
}
