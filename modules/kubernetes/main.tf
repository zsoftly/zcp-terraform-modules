resource "cloudstack_kubernetes_cluster" "this" {
  name               = var.name
  zone               = var.zone
  kubernetes_version = var.kubernetes_version
  service_offering   = var.service_offering

  size               = var.worker_count
  control_nodes_size = var.control_plane_count
  etcd_nodes_size    = var.etcd_count
  description        = var.description
  hypervisor         = var.hypervisor

  noderootdisksize = var.node_root_disk_size
  node_offerings   = length(local.node_offerings) > 0 ? local.node_offerings : null
  node_templates   = length(local.node_templates) > 0 ? local.node_templates : null

  autoscaling_enabled = var.autoscaling_enabled
  min_size            = var.autoscaling_min_size
  max_size            = var.autoscaling_max_size

  network_id = var.network_id
  keypair    = var.keypair

  cni_configuration_id = var.cni_configuration_id
  cni_config_details   = var.cni_config_details

  project   = var.project
  domain_id = var.domain_id
  account   = var.account

  docker_registry_url      = var.docker_registry_url
  docker_registry_username = var.docker_registry_username
  docker_registry_password = var.docker_registry_password
}
