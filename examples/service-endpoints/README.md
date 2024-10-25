# Service Endpoints

This deploys service endpoints on a subnet

## Types

```hcl
vnet = object({
  existing = object({
    name           = string
    location       = string
    resource_group = string
    cidr           = list(string)
    subnets = map(object({
      cidr = list(string)
      nsg = optional(map(string))
      service_endpoints = optional(list(string))
    }))
  })
})
```
