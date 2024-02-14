variable "vnet" {
  description = "Contains all log analytics workspace settings"
  type        = any
}

variable "naming" {
  description = "Used for naming purposes"
  type        = map(string)
  default     = null
}
