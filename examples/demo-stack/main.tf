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

module "kubernetes" {
  for_each = var.kubernetes_clusters

  source = "../../modules/kubernetes"

  name                     = each.value.name
  description              = each.value.description
  zone                     = var.zone
  kubernetes_version       = each.value.kubernetes_version
  service_offering         = each.value.service_offering
  worker_count             = each.value.worker_count
  control_plane_count      = each.value.control_plane_count
  etcd_count               = each.value.etcd_count
  node_root_disk_size      = each.value.node_root_disk_size
  node_offerings           = each.value.node_offerings
  node_templates           = each.value.node_templates
  autoscaling_enabled      = each.value.autoscaling_enabled
  autoscaling_min_size     = each.value.autoscaling_min_size
  autoscaling_max_size     = each.value.autoscaling_max_size
  network_id               = each.value.network_id
  keypair                  = each.value.keypair
  hypervisor               = each.value.hypervisor
  cni_configuration_id     = each.value.cni_configuration_id
  cni_config_details       = each.value.cni_config_details
  project                  = var.project
  domain_id                = each.value.domain_id
  account                  = each.value.account
  docker_registry_url      = each.value.docker_registry_url
  docker_registry_username = each.value.docker_registry_username
  docker_registry_password = try(var.kubernetes_docker_registry_passwords[each.key], null)
}

module "accounts_projects" {
  source = "../../modules/accounts-projects"

  domains  = nonsensitive(var.accounts_projects.domains)
  roles    = nonsensitive(var.accounts_projects.roles)
  accounts = var.accounts_projects.accounts
  users    = var.accounts_projects.users
  projects = nonsensitive(var.accounts_projects.projects)
  quotas   = nonsensitive(var.accounts_projects.quotas)
}

module "vpn_connectivity" {
  source = "../../modules/vpn-connectivity"

  # "demo" must match a key in var.networking_vpcs
  vpc_id            = module.networking["demo"].vpc.id
  project           = var.project
  customer_gateways = var.vpn_customer_gateways
}

resource "terraform_data" "validate_compute_groups" {
  for_each = var.compute_groups

  lifecycle {
    precondition {
      condition     = contains(keys(var.networking_vpcs), each.value.vpc_key)
      error_message = "compute_groups[\"${each.key}\"].vpc_key = \"${each.value.vpc_key}\" not found in networking_vpcs. Valid keys: [${join(", ", keys(var.networking_vpcs))}]."
    }
    precondition {
      condition     = !contains(keys(var.networking_vpcs), each.value.vpc_key) || contains(keys(var.networking_vpcs[each.value.vpc_key].networks), each.value.network_key)
      error_message = "compute_groups[\"${each.key}\"].network_key = \"${each.value.network_key}\" not found under networking_vpcs[\"${each.value.vpc_key}\"].networks."
    }
  }
}

module "compute" {
  for_each = var.compute_groups

  source = "../../modules/compute"

  depends_on = [terraform_data.validate_compute_groups]

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
