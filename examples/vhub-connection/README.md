## Usage: virtual hub connection

```hcl
module "vhub-connection" {
  source  = "cloudnationhq/vnet/modules/vhub-connection/azure"
  version = "~> 0.1"

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
