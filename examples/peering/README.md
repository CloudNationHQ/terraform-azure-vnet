# Default

This example illustrates a virtual network peering both ways between two virtual networks, a local and remote.
address_space used for trigger when address_space changes of a remote vnet then it will resync again. 


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
