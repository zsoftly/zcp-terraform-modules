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

module "compute" {
  for_each = var.compute_groups

  source = "../../modules/compute"

  zone                     = var.zone
  project                  = var.project
  tags                     = merge(var.tags, each.value.tags)
  default_service_offering = each.value.default_service_offering
  default_template         = each.value.default_template
  default_network_id       = module.networking[each.value.vpc_key].network_ids[each.value.network_key]

  create_ssh_keypair = each.value.create_ssh_keypair
  ssh_keypair_name   = each.value.ssh_keypair_name
  ssh_public_key     = each.value.ssh_public_key

  affinity_groups = each.value.affinity_groups
  instances       = each.value.instances
}
