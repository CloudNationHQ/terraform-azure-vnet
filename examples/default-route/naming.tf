locals {
  naming = {
    for type in local.naming_types : type => module.naming[type].name
  }

  naming_types = [
    "route",
    "route_table",
    "subnet",
  ]
}
