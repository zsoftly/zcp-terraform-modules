resource "cloudstack_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  name           = var.name
  display_text   = var.display_text
  cidr           = var.cidr
  vpc_offering   = var.vpc_offering
  zone           = var.zone
  network_domain = var.network_domain
  project        = var.project
  tags           = var.tags
}

resource "cloudstack_network_acl" "this" {
  for_each = var.network_acls

  name        = each.value.name
  description = try(each.value.description, each.value.name)
  vpc_id      = local.vpc_id
  project     = var.project

  depends_on = [cloudstack_vpc.this]
}

resource "cloudstack_network_acl_rule" "this" {
  for_each = {
    for rule in local.network_acl_rules : rule.key => rule
  }

  acl_id  = cloudstack_network_acl.this[each.value.acl_key].id
  project = var.project

  rule {
    rule_number  = each.value.rule_number
    action       = each.value.action
    cidr_list    = each.value.cidr_list
    protocol     = each.value.protocol
    port         = each.value.port
    icmp_type    = each.value.icmp_type
    icmp_code    = each.value.icmp_code
    traffic_type = each.value.traffic_type
    description  = each.value.description
  }
}

resource "cloudstack_network" "this" {
  for_each = var.networks

  name             = each.value.name
  display_text     = try(each.value.display_text, each.value.name)
  cidr             = each.value.cidr
  gateway          = try(each.value.gateway, null)
  startip          = try(each.value.startip, null)
  endip            = try(each.value.endip, null)
  network_domain   = try(each.value.network_domain, var.network_domain)
  network_offering = each.value.network_offering
  vlan             = try(each.value.vlan, null)
  vpc_id           = try(each.value.attach_to_vpc, true) ? local.vpc_id : null
  acl_id           = try(each.value.acl_key, null) != null ? cloudstack_network_acl.this[each.value.acl_key].id : null
  project          = var.project
  source_nat_ip    = try(each.value.source_nat_ip, false)
  zone             = var.zone
  tags             = merge(var.tags, try(each.value.tags, {}))

  depends_on = [
    cloudstack_network_acl_rule.this,
    cloudstack_vpc.this,
  ]
}
