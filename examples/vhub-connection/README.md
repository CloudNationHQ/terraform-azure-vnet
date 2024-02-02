This example showcases the integration of a virtual network with azure virtual wan by establishing a vhub connection. This connection extends network capabilities by allowing seamless interconnectivity between distributed network segments.

## Usage: virtual hub connection

```hcl
module "vhub-connection" {
  source  = "cloudnationhq/vnet/azure//modules/vhub-connection"
  version = "~> 1.2"

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
```
