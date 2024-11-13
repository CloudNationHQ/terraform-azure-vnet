# Default

This example illustrates the default setup, in its simplest form.

## Types

```hcl
vnet = object({
  name           = string
  location       = string
  resource_group = string
  address_space  = list(string)
})
```
