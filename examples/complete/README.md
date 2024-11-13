# Complete

This example highlights the complete usage.

## Types

```hcl
vnet = object({
  name           = string
  location       = string
  resource_group = string
  address_space  = list(string)
  subnets = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string))
    delegations = optional(map(object({
      name = string
      actions = list(string)
    })))
    route_table = optional(object({
      routes = map(object({
        address_prefix = string
        next_hop_type = string
      }))
    }))
    network_security_group = optional(object({
      rules = map(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range         = string
        destination_port_range    = string
        source_address_prefixes   = optional(list(string))
        source_address_prefix     = optional(string)
        destination_address_prefix = string
      }))
    }))
  }))
})
```
