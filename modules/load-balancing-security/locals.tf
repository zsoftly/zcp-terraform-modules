locals {
  public_ip_ids = merge(
    var.existing_public_ip_ids,
    {
      for key, ip in cloudstack_ipaddress.this : key => ip.id
    }
  )

  firewall_ip_address_ids = {
    for key, firewall in var.firewalls :
    key => try(firewall.public_ip_key, null) != null ? try(local.public_ip_ids[firewall.public_ip_key], null) : try(firewall.ip_address_id, null)
  }

  static_nat_ip_address_ids = {
    for key, static_nat in var.static_nats :
    key => try(static_nat.public_ip_key, null) != null ? try(local.public_ip_ids[static_nat.public_ip_key], null) : try(static_nat.ip_address_id, null)
  }

  port_forward_ip_address_ids = {
    for key, port_forward in var.port_forwards :
    key => try(port_forward.public_ip_key, null) != null ? try(local.public_ip_ids[port_forward.public_ip_key], null) : try(port_forward.ip_address_id, null)
  }

  load_balancer_ip_address_ids = {
    for key, load_balancer in var.load_balancer_rules :
    key => try(load_balancer.public_ip_key, null) != null ? try(local.public_ip_ids[load_balancer.public_ip_key], null) : try(load_balancer.ip_address_id, null)
  }
}
