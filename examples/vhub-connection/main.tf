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
    cidr           = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        network_security_group = {}
        cidr                   = ["10.19.1.0/24"]
      }
    }
  }
}

module "vhub-connection" {
  source  = "cloudnationhq/vnet/azure//modules/vhub-connection"
  version = "~> 4.0"

  providers = {
    azurerm = azurerm.connectivity
  }

  virtual_hub = {
    name           = "vhub-westeurope"
    resource_group = "rg-vwan-shared"
    connection     = module.naming.virtual_hub_connection.name
    vnet           = module.network.vnet.id
  }
}
