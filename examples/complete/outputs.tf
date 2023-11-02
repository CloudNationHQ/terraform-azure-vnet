output "vnet" {
  value = module.network.vnet
}

output "subnets" {
  value = { for s in module.network.subnets : s.name => {
    id   = s.id
    name = s.name
    }
  }
}

output "subscriptionId" {
  value = module.network.subscriptionId
}
