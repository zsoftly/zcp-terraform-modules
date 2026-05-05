output "vpc" {
  description = "Created or referenced VPC details."
  value = {
    id            = local.vpc_id
    name          = var.create_vpc ? cloudstack_vpc.this[0].name : var.name
    cidr          = var.cidr
    source_nat_ip = var.create_vpc ? cloudstack_vpc.this[0].source_nat_ip : null
  }
}

output "network_acls" {
  description = "Created network ACL IDs keyed by input key."
  value = {
    for key, acl in cloudstack_network_acl.this : key => {
      id          = acl.id
      name        = acl.name
      description = acl.description
    }
  }
}

output "networks" {
  description = "Created network details keyed by input key."
  value = {
    for key, network in cloudstack_network.this : key => {
      id                    = network.id
      name                  = network.name
      cidr                  = network.cidr
      gateway               = network.gateway
      startip               = network.startip
      endip                 = network.endip
      vpc_id                = network.vpc_id
      source_nat_ip_address = network.source_nat_ip_address
      source_nat_ip_id      = network.source_nat_ip_id
    }
  }
}

output "network_ids" {
  description = "Created network IDs keyed by input key."
  value = {
    for key, network in cloudstack_network.this : key => network.id
  }
}

output "network_cidrs" {
  description = "Created network CIDRs keyed by input key."
  value = {
    for key, network in cloudstack_network.this : key => network.cidr
  }
}

output "zcp_offerings" {
  description = "ZCP offering names this module is designed to consume."
  value       = local.zcp_offerings
}
