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
