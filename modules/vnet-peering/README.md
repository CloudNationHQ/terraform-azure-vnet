# Virtual Network Peering

This submodule allows for a bidirectional virtual network peering between two networks: a local virtual network and a remote virtual network. The configuration ensures seamless connectivity between both networks.

The `address_space` attribute within the `vnet_peering` object variable is optional and can be provided if you want the peering to automatically **resync** when changes to the address space of the remote virtual network occur. A **resync** ensures that updated routes are **propagated** between the networks, allowing traffic to flow correctly after changes, such as when a new subnet is added or an existing one is modified. If the `address_space` attribute is omitted, no automatic **resync** will be triggered upon address space changes.

## Notes
This submodule supports virtual network peering between networks in different subscriptions. To enable this, a provider alias `(azurerm.remote)` has been configured using `configuration_aliases = [azurerm.remote]`.

**Peering with a virtual network in another subscription**

To peer with a virtual network in a different subscription, you can set up the provider alias as follows:

```hcl
providers = {
  azurerm.remote = azurerm.remote
}
```

You will also need to configure the azurerm provider with the appropriate subscription ID for the remote virtual network:

```hcl
provider "azurerm" {
  alias           = "remote"
  subscription_id = "00000000-0000-0000-0000-000000000000"
  features {}
}
```
Peering with a Virtual Network in the Same Subscription
If the remote virtual network is in the same subscription, you can simply reference the default provider without setting up an alias:

hcl
Copy code
providers = {
  azurerm.remote = azurerm
}
Limitations
At this time, peering across different tenants is not supported.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |
| <a name="provider_azurerm.remote"></a> [azurerm.remote](#provider\_azurerm.remote) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_network_peering.local_to_remote](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [azurerm_virtual_network_peering.remote_to_local](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vnet_peering"></a> [vnet\_peering](#input\_vnet\_peering) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vnet_peering"></a> [vnet\_peering](#output\_vnet\_peering) | contains vnet peering configuration |
<!-- END_TF_DOCS -->
