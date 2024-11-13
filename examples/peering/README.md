# Default

This example demonstrates bidirectional virtual network peering between two networks: a local virtual network and a remote virtual network. The configuration ensures seamless connectivity between both networks.

The `address_space` attribute is optional and can be provided if you want the peering to automatically **resync** when changes to the address space of the remote virtual network occur. A **resync** ensures that updated routes are **propagated** between the networks, allowing traffic to flow correctly after changes, such as when a new subnet is added or an existing one is modified. If the `address_space` attribute is omitted, no automatic **resync** will be triggered upon address space changes.

## Types

```hcl
vnet_peering = object({
  local = object({
    name                 = string
    id                   = string
    resource_group_name  = string
    address_space        = optional(list(string))

    allow_virtual_network_access           = optional(bool)
    allow_forwarded_traffic                = optional(bool)
    allow_gateway_transit                  = optional(bool)
    only_ipv6_peering_enabled              = optional(bool)
    peer_complete_virtual_networks_enabled = optional(bool)
    local_subnet_names                     = optional(list(string))
    remote_subnet_names                    = optional(list(string))
  })
  remote = object({
    name                 = string
    id                   = string
    resource_group_name  = string
    address_space        = optional(list(string))

    allow_virtual_network_access           = optional(bool)
    allow_forwarded_traffic                = optional(bool)
    allow_gateway_transit                  = optional(bool)
    only_ipv6_peering_enabled              = optional(bool)
    peer_complete_virtual_networks_enabled = optional(bool)
    local_subnet_names                     = optional(list(string))
    remote_subnet_names                    = optional(list(string))
  })
})
```

**Notes:** 
You can use a more concise approach by passing the entire vnet object directly, instead of specifying individual attributes for the local and remote networks. This simplifies the configuration:

```hcl
module "peering" {
  source = "cloudnationhq/vnet/azure//modules/vnet-peering"
  version = "~> 1.0"

  providers = {
    azurerm.remote = azurerm.remote
  }

  vnet_peering = {
    local  = module.vnet_local.vnet
    remote = module.vnet_remote.vnet
  }
}
```