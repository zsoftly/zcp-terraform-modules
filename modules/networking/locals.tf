locals {
  vpc_id = var.create_vpc ? cloudstack_vpc.this[0].id : var.existing_vpc_id

  acs_offerings = {
    vpc = {
      prd    = "Standard VPC offering"
      nonprd = "Standard VPC offering - nonprd"
    }

    network = {
      vpc_tier              = "VPC Tier"
      isolated_source_nat   = "Isolated Network with Source NAT"
      isolated_console_only = "Isolated Network Console Only"
      shared                = "Shared Network"
    }
  }

  network_acl_rules = flatten([
    for acl_key, acl in var.network_acls : [
      for rule_index, rule in acl.rules : {
        key          = "${acl_key}-${rule_index}"
        acl_key      = acl_key
        rule_number  = try(rule.rule_number, null)
        action       = lower(try(rule.action, "allow"))
        cidr_list    = rule.cidr_list
        protocol     = lower(rule.protocol)
        port         = try(rule.port, null)
        icmp_type    = try(rule.icmp_type, null)
        icmp_code    = try(rule.icmp_code, null)
        traffic_type = lower(try(rule.traffic_type, "ingress"))
        description  = try(rule.description, null)
      }
    ]
  ])
}
