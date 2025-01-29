module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.22"

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

module "rg_remote" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  providers = {
    azurerm = azurerm.remote
  }

  groups = {
    demo = {
      name     = "${module.naming.resource_group.name_unique}-remote"
      location = "northeurope"
    }
  }
}


module "vnet_local" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 8.0"

  naming = local.naming

  vnet = {
    name           = "${module.naming.virtual_network.name}-hub"
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
    address_space  = ["10.0.0.0/16"]
  }
}

module "vnet_remote" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 8.0"

  naming = local.naming

  providers = {
    azurerm = azurerm.remote
  }

  vnet = {
    name           = "${module.naming.virtual_network.name}-spoke"
    location       = module.rg_remote.groups.demo.location
    resource_group = module.rg_remote.groups.demo.name
    address_space  = ["10.1.0.0/16"]
  }
}

module "peering" {
  source  = "cloudnationhq/vnet/azure//modules/vnet-peering"
  version = "~> 8.0"

  providers = {
    azurerm.remote = azurerm.remote
  }

  vnet_peering = {
    local = {
      peering_name        = "local-to-remote"
      name                = module.vnet_local.vnet.name
      id                  = module.vnet_local.vnet.id
      resource_group_name = module.vnet_local.vnet.resource_group_name
      address_space       = module.vnet_local.vnet.address_space
    }
    remote = {
      peering_name        = "remote-to-local"
      name                = module.vnet_remote.vnet.name
      id                  = module.vnet_remote.vnet.id
      resource_group_name = module.vnet_remote.vnet.resource_group_name
      address_space       = module.vnet_remote.vnet.address_space
    }
  }
}
