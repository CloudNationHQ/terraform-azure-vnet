variable "vnet_peering" {
  description = "Configuration for bidirectional VNet peering between local and remote virtual networks"
  type = object({
    local = object({
      name                                   = string
      id                                     = string
      resource_group_name                    = string
      address_space                          = optional(list(string), [])
      peering_name                           = optional(string, null)
      allow_virtual_network_access           = optional(bool, true)
      allow_forwarded_traffic                = optional(bool, false)
      allow_gateway_transit                  = optional(bool, false)
      only_ipv6_peering_enabled              = optional(bool, false)
      peer_complete_virtual_networks_enabled = optional(bool, true)
      subnet_names                           = optional(list(string), [])
      use_remote_gateways                    = optional(bool, false)
    })
    remote = object({
      name                                   = string
      id                                     = string
      resource_group_name                    = string
      address_space                          = optional(list(string), [])
      peering_name                           = optional(string, null)
      allow_virtual_network_access           = optional(bool, true)
      allow_forwarded_traffic                = optional(bool, false)
      allow_gateway_transit                  = optional(bool, false)
      only_ipv6_peering_enabled              = optional(bool, false)
      peer_complete_virtual_networks_enabled = optional(bool, true)
      subnet_names                           = optional(list(string), [])
      use_remote_gateways                    = optional(bool, false)
    })
  })

  validation {
    condition = (
      var.vnet_peering.local.allow_gateway_transit == false ||
      var.vnet_peering.local.use_remote_gateways == false
    )
    error_message = "Local VNet cannot have both allow_gateway_transit and use_remote_gateways set to true."
  }

  validation {
    condition = (
      var.vnet_peering.remote.allow_gateway_transit == false ||
      var.vnet_peering.remote.use_remote_gateways == false
    )
    error_message = "Remote VNet cannot have both allow_gateway_transit and use_remote_gateways set to true."
  }

  validation {
    condition     = var.vnet_peering.local.id != var.vnet_peering.remote.id
    error_message = "Local and remote virtual network IDs must be different."
  }
}
