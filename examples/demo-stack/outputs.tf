output "vpcs" {
  description = "VPC details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.vpc
  }
}

output "network_acls" {
  description = "Network ACL details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_acls
  }
}

output "networks" {
  description = "Network details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.networks
  }
}

output "network_ids" {
  description = "Network IDs keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_ids
  }
}

output "network_cidrs" {
  description = "Network CIDRs keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_cidrs
  }
}
