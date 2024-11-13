# Service Endpoints

This deploys service endpoints on a subnet

## Types

```hcl
vnet = object({
  existing = object({
    name           = string
    location       = string
    resource_group = string
    address_space  = list(string)
    subnets = map(object({
      address_prefixes       = list(string)
      network_security_group = optional(map(string))
      service_endpoints      = optional(list(string))
    }))
  })
})
```
