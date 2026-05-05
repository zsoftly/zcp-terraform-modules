module "networking" {
  for_each = var.networking_vpcs

  source = "../../modules/networking"

  name           = each.value.name
  display_text   = try(each.value.display_text, each.value.name)
  cidr           = each.value.cidr
  zone           = var.zone
  vpc_offering   = each.value.vpc_offering
  network_domain = try(each.value.network_domain, null)
  project        = var.project
  tags           = merge(var.tags, try(each.value.tags, {}))

  network_acls = try(each.value.network_acls, {})
  networks     = each.value.networks
}

module "load_balancing_security" {
  for_each = var.load_balancing_security

  source = "../../modules/load-balancing-security"

  name       = each.value.name
  zone       = var.zone
  project    = var.project
  network_id = try(each.value.network_id, null) != null ? each.value.network_id : try(module.networking[each.value.networking_vpc_key].network_ids[each.value.network_key], null)
  vpc_id     = try(each.value.vpc_id, null)

  existing_public_ip_ids = try(each.value.existing_public_ip_ids, {})
  public_ips             = try(each.value.public_ips, {})
  firewalls              = try(each.value.firewalls, {})
  egress_firewalls       = try(each.value.egress_firewalls, {})
  static_nats            = try(each.value.static_nats, {})
  port_forwards          = try(each.value.port_forwards, {})
  load_balancer_rules    = try(each.value.load_balancer_rules, {})
}
