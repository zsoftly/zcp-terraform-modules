resource "cloudstack_ipaddress" "this" {
  for_each = var.public_ips

  is_portable = try(each.value.is_portable, false)
  network_id  = try(each.value.network_id, null) != null ? each.value.network_id : var.network_id
  vpc_id      = try(each.value.vpc_id, null) != null ? each.value.vpc_id : var.vpc_id
  zone        = try(each.value.zone, null) != null ? each.value.zone : var.zone
  project     = var.project
}

resource "cloudstack_firewall" "this" {
  for_each = var.firewalls

  ip_address_id = local.firewall_ip_address_ids[each.key]
  managed       = try(each.value.managed, false)
  parallelism   = try(each.value.parallelism, 2)

  dynamic "rule" {
    for_each = each.value.rules

    content {
      cidr_list = rule.value.cidr_list
      protocol  = rule.value.protocol
      ports     = try(rule.value.ports, null)
      icmp_type = try(rule.value.icmp_type, null)
      icmp_code = try(rule.value.icmp_code, null)
    }
  }
}

resource "cloudstack_egress_firewall" "this" {
  for_each = var.egress_firewalls

  network_id  = try(each.value.network_id, null) != null ? each.value.network_id : var.network_id
  managed     = try(each.value.managed, false)
  parallelism = try(each.value.parallelism, 2)

  dynamic "rule" {
    for_each = each.value.rules

    content {
      cidr_list = rule.value.cidr_list
      protocol  = rule.value.protocol
      ports     = try(rule.value.ports, null)
      icmp_type = try(rule.value.icmp_type, null)
      icmp_code = try(rule.value.icmp_code, null)
    }
  }
}

resource "cloudstack_static_nat" "this" {
  for_each = var.static_nats

  ip_address_id      = local.static_nat_ip_address_ids[each.key]
  virtual_machine_id = each.value.virtual_machine_id
  vm_guest_ip        = try(each.value.vm_guest_ip, null)
  project            = var.project
}

resource "cloudstack_port_forward" "this" {
  for_each = var.port_forwards

  ip_address_id = local.port_forward_ip_address_ids[each.key]
  managed       = try(each.value.managed, false)
  project       = var.project

  dynamic "forward" {
    for_each = each.value.forwards

    content {
      protocol           = forward.value.protocol
      private_port       = forward.value.private_port
      public_port        = forward.value.public_port
      virtual_machine_id = forward.value.virtual_machine_id
      vm_guest_ip        = try(forward.value.vm_guest_ip, null)
    }
  }
}

resource "cloudstack_loadbalancer_rule" "this" {
  for_each = var.load_balancer_rules

  name          = each.value.name
  description   = try(each.value.description, each.value.name)
  ip_address_id = local.load_balancer_ip_address_ids[each.key]
  network_id    = try(each.value.network_id, null) != null ? each.value.network_id : var.network_id
  algorithm     = each.value.algorithm
  private_port  = each.value.private_port
  public_port   = each.value.public_port
  protocol      = try(each.value.protocol, "tcp")
  member_ids    = each.value.member_ids
  project       = var.project
}
