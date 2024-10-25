# Delegations

This deploys delegations on a subnet

## Types

```hcl
vnet = object({
  name           = string
  location       = string
  resource_group = string
  cidr           = list(string)
  dns_servers    = list(string)
  subnets = map(object({
    cidr = list(string)
    delegations = optional(map(object({
      name = string
      actions = optional(list(string))
    })))
  }))
})
```
