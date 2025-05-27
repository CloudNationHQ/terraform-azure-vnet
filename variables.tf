variable "vnet" {
  description = "Contains all virtual network configuration"
  type = object({
    name                           = string
    address_space                  = optional(list(string))
    resource_group_name            = optional(string)
    location                       = optional(string)
    use_existing_vnet              = optional(bool, false)
    edge_zone                      = optional(string)
    bgp_community                  = optional(string)
    flow_timeout_in_minutes        = optional(number)
    private_endpoint_vnet_policies = optional(string)
    dns_servers                    = optional(list(string), [])
    tags                           = optional(map(string))
    ddos_protection_plan = optional(object({
      id     = string
      enable = optional(bool, true)
    }))
    encryption = optional(object({
      enforcement = string
    }))
    subnets = optional(map(object({
      name                                          = optional(string)
      address_prefixes                              = list(string)
      service_endpoints                             = optional(list(string), [])
      private_link_service_network_policies_enabled = optional(bool, false)
      private_endpoint_network_policies             = optional(string, "Disabled")
      service_endpoint_policy_ids                   = optional(list(string), [])
      default_outbound_access_enabled               = optional(bool, null)
      delegations = optional(map(object({
        name    = string
        actions = optional(list(string), [])
      })), {})
      network_security_group = optional(object({
        name = optional(string)
        rules = optional(map(object({
          name                                       = optional(string)
          priority                                   = number
          direction                                  = string
          access                                     = string
          protocol                                   = string
          source_port_range                          = optional(string)
          source_port_ranges                         = optional(list(string))
          destination_port_range                     = optional(string)
          destination_port_ranges                    = optional(list(string))
          source_address_prefix                      = optional(string)
          source_address_prefixes                    = optional(list(string))
          destination_address_prefix                 = optional(string)
          destination_address_prefixes               = optional(list(string))
          description                                = optional(string)
          source_application_security_group_ids      = optional(list(string), [])
          destination_application_security_group_ids = optional(list(string), [])
        })), {})
      }))
      route_table = optional(object({
        name                          = optional(string)
        bgp_route_propagation_enabled = optional(bool, true)
        routes = optional(map(object({
          name                   = optional(string)
          address_prefix         = string
          next_hop_type          = string
          next_hop_in_ip_address = optional(string, null)
        })), {})
      }))
      shared = optional(object({
        network_security_group = optional(string)
        route_table            = optional(string)
      }), {})
    })), {})
    network_security_groups = optional(map(object({
      name = optional(string)
      rules = optional(map(object({
        name                                       = optional(string)
        priority                                   = number
        direction                                  = string
        access                                     = string
        protocol                                   = string
        source_port_range                          = optional(string)
        source_port_ranges                         = optional(list(string), null)
        destination_port_range                     = optional(string, null)
        destination_port_ranges                    = optional(list(string), null)
        source_address_prefix                      = optional(string, null)
        source_address_prefixes                    = optional(list(string), null)
        destination_address_prefix                 = optional(string, null)
        destination_address_prefixes               = optional(list(string), null)
        description                                = optional(string, null)
        source_application_security_group_ids      = optional(list(string), [])
        destination_application_security_group_ids = optional(list(string), [])
      })), {})
    })), {})
    route_tables = optional(map(object({
      name                          = optional(string)
      bgp_route_propagation_enabled = optional(bool, true)
      routes = optional(map(object({
        name                   = optional(string)
        address_prefix         = string
        next_hop_type          = string
        next_hop_in_ip_address = optional(string, null)
      })), {})
    })), {})
  })
  validation {
    condition     = var.vnet.location != null || var.location != null
    error_message = "location must be provided either in the vnet object or as a separate variable."
  }

  validation {
    condition     = var.vnet.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the vnet object or as a separate variable."
  }
}

variable "use_existing_vnet" {
  description = "Whether to use existing VNet for all vnets"
  type        = bool
  default     = false
}

variable "naming" {
  description = "Used for naming purposes"
  type        = map(string)
  default     = null
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
