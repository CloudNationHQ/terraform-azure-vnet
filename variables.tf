variable "vnet" {
  description = "Contains all virtual network configuration"
  type = object({
    name          = string
    address_space = optional(set(string))
    ip_address_pool = optional(object({
      id                     = string
      number_of_ip_addresses = string
    }))
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
      address_prefixes                              = optional(list(string))
      service_endpoints                             = optional(set(string), [])
      private_link_service_network_policies_enabled = optional(bool, false)
      private_endpoint_network_policies             = optional(string, "Disabled")
      service_endpoint_policy_ids                   = optional(set(string), [])
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
          source_port_ranges                         = optional(set(string))
          destination_port_range                     = optional(string)
          destination_port_ranges                    = optional(set(string))
          source_address_prefix                      = optional(string)
          source_address_prefixes                    = optional(set(string))
          destination_address_prefix                 = optional(string)
          destination_address_prefixes               = optional(set(string))
          description                                = optional(string)
          source_application_security_group_ids      = optional(set(string), [])
          destination_application_security_group_ids = optional(set(string), [])
        })), {})
        tags = optional(map(string))
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
        tags = optional(map(string))
      }))
      ip_address_pool = optional(object({
        id                     = string
        number_of_ip_addresses = string
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
        source_port_ranges                         = optional(set(string))
        destination_port_range                     = optional(string)
        destination_port_ranges                    = optional(set(string))
        source_address_prefix                      = optional(string)
        source_address_prefixes                    = optional(set(string))
        destination_address_prefix                 = optional(string)
        destination_address_prefixes               = optional(set(string))
        description                                = optional(string)
        source_application_security_group_ids      = optional(set(string), [])
        destination_application_security_group_ids = optional(set(string), [])
      })), {})
      tags = optional(map(string))
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
      tags = optional(map(string))
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

  validation {
    condition     = (var.vnet.address_space != null && var.vnet.ip_address_pool == null) || (var.vnet.address_space == null && var.vnet.ip_address_pool != null)
    error_message = "exactly one of address_space or ip_address_pool must be specified."
  }

  validation {
    condition = alltrue([
      for subnet in keys(var.vnet.subnets) : (
        var.vnet.subnets[subnet].shared.network_security_group == null ||
        try(contains(keys(var.vnet.network_security_groups), var.vnet.subnets[subnet].shared.network_security_group), false)
      )
    ])
    error_message = "One or more subnets reference a shared network_security_group that does not exist in network_security_groups."
  }
  validation {
    condition = alltrue([
      for subnet in keys(var.vnet.subnets) : (
        var.vnet.subnets[subnet].shared.route_table == null ||
        try(contains(keys(var.vnet.route_tables), var.vnet.subnets[subnet].shared.route_table), false)
      )
    ])
    error_message = "One or more subnets reference a shared route_table that does not exist in route_tables."
  }

  validation {
    condition = var.vnet.address_space == null ? true : alltrue(flatten([
      for subnet in values(var.vnet.subnets) : [
        for prefix in subnet.address_prefixes :
        can(cidrhost(prefix, 0)) &&
        anytrue([
          for vnet_space in var.vnet.address_space :
          can(cidrhost(vnet_space, 0)) &&
          (
            (
              tonumber(element(split(".", cidrhost(prefix, 0)), 0)) * 256 * 256 * 256 +
              tonumber(element(split(".", cidrhost(prefix, 0)), 1)) * 256 * 256 +
              tonumber(element(split(".", cidrhost(prefix, 0)), 2)) * 256 +
              tonumber(element(split(".", cidrhost(prefix, 0)), 3))
              ) >= (
              tonumber(element(split(".", cidrhost(vnet_space, 0)), 0)) * 256 * 256 * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, 0)), 1)) * 256 * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, 0)), 2)) * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, 0)), 3))
            )
          ) &&
          (
            (
              tonumber(element(split(".", cidrhost(prefix, -1)), 0)) * 256 * 256 * 256 +
              tonumber(element(split(".", cidrhost(prefix, -1)), 1)) * 256 * 256 +
              tonumber(element(split(".", cidrhost(prefix, -1)), 2)) * 256 +
              tonumber(element(split(".", cidrhost(prefix, -1)), 3))
              ) <= (
              tonumber(element(split(".", cidrhost(vnet_space, -1)), 0)) * 256 * 256 * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, -1)), 1)) * 256 * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, -1)), 2)) * 256 +
              tonumber(element(split(".", cidrhost(vnet_space, -1)), 3))
            )
          )
        ])
      ]
    ]))
    error_message = "All subnet address prefixes must be within the VNet address space."
  }

  validation {
    condition = alltrue([
      for nsg in concat(
        [for subnet in values(var.vnet.subnets) : lookup(subnet, "network_security_group", null)],
        values(var.vnet.network_security_groups)
        ) : nsg != null ? (
        alltrue([
          for direction in ["Inbound", "Outbound"] :
          length(distinct([
            for rule in values(nsg.rules) :
            rule.priority if rule.direction == direction
            ])) == length([
            for rule in values(nsg.rules) :
            rule if rule.direction == direction
          ])
        ])
      ) : true
    ])
    error_message = "Each NSG rule must have a unique priority within its NSG per direction (Inbound/Outbound)."
  }

  validation {
    condition = alltrue([
      for subnet in values(var.vnet.subnets) :
      (subnet.address_prefixes != null && subnet.ip_address_pool == null) || (subnet.address_prefixes == null && subnet.ip_address_pool != null)
    ])
    error_message = "Each subnet must specify exactly one of address_prefixes or ip_address_pool."
  }
}

# Optional explicit subnet keys to force plan-time stable keys when calling module
variable "subnet_keys" {
  description = "Optional list of subnet keys to force static for_each keys when subnets map values are unknown at plan time."
  type        = list(string)
  default     = null
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
