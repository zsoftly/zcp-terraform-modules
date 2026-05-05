output "public_ips" {
  description = "Public IP details keyed by input public IP key."
  value = {
    for key, ip in cloudstack_ipaddress.this : key => {
      id         = ip.id
      ip_address = ip.ip_address
    }
  }
}

output "public_ip_ids" {
  description = "All public IP IDs available to this module, including existing_public_ip_ids."
  value       = local.public_ip_ids
}

output "firewall_rule_sets" {
  description = "Ingress firewall resources keyed by input key."
  value = {
    for key, firewall in cloudstack_firewall.this : key => {
      id = firewall.id
    }
  }
}

output "egress_firewall_rule_sets" {
  description = "Egress firewall resources keyed by input key."
  value = {
    for key, firewall in cloudstack_egress_firewall.this : key => {
      id = firewall.id
    }
  }
}

output "static_nats" {
  description = "Static NAT resources keyed by input key."
  value = {
    for key, static_nat in cloudstack_static_nat.this : key => {
      id          = static_nat.id
      vm_guest_ip = static_nat.vm_guest_ip
    }
  }
}

output "port_forwards" {
  description = "Port forwarding resources keyed by input key."
  value = {
    for key, port_forward in cloudstack_port_forward.this : key => {
      id          = port_forward.id
      vm_guest_ip = port_forward.vm_guest_ip
    }
  }
}

output "load_balancer_rules" {
  description = "Load balancer rules keyed by input key."
  value = {
    for key, rule in cloudstack_loadbalancer_rule.this : key => {
      id          = rule.id
      name        = rule.name
      description = rule.description
    }
  }
}
