# Nsg Rules

This deploys network security groups and rules both shared as individual on a subnet

## Types

```hcl
vnet = object({
  name           = string
  location       = string
  resource_group = string
  cidr           = list(string)
  subnets = map(object({
    cidr = list(string)
    shared = optional(object({
      network_security_group = string
    }))
    network_security_group = optional(object({
      rules = map(object({
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      }))
    }))
  }))
  network_security_groups = optional(map(object({
    rules = map(object({
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  })))
})
```
