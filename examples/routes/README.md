# Routes

This deploys route tables and routes both shared as individual on a subnet

## Types

```hcl
vnet = object({
  name           = string
  location       = string
  resource_group = string
  address_space  = list(string)
  subnets = map(object({
    address_prefixes = list(string)
    shared = optional(object({
      route_table = string
    }))
    route_table = optional(object({
      routes = map(object({
        address_prefix = string
        next_hop_type = string
      }))
    }))
  }))
  route_tables = optional(map(object({
    routes = map(object({
      address_prefix = string
      next_hop_type = string
    }))
  })))
})
```
