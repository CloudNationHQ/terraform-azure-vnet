variable "vnet" {
  description = "Contains all virtual network settings"
  type        = any
}

variable "use_existing_vnet" {
  description = "use existing vnets globally"
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

variable "resource_group" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
