This example showcases virtual wan integration by establishing a vhub connection.

## Usage: virtual hub connection

```hcl
module "vhub-connection" {
  source  = "cloudnationhq/vnet/azure//modules/vhub-connection"
  version = "~> 2.7"

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
