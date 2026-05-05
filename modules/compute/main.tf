resource "cloudstack_ssh_keypair" "this" {
  count = var.create_ssh_keypair ? 1 : 0

  name       = var.ssh_keypair_name
  public_key = var.ssh_public_key
  project    = var.project

  lifecycle {
    precondition {
      condition     = var.ssh_keypair_name != null
      error_message = "ssh_keypair_name is required when create_ssh_keypair is true."
    }
    precondition {
      condition     = var.ssh_public_key != null
      error_message = "ssh_public_key is required when create_ssh_keypair is true."
    }
  }
}

resource "cloudstack_affinity_group" "this" {
  for_each = var.affinity_groups

  name        = each.value.name
  type        = each.value.type
  description = each.value.description != null ? each.value.description : each.value.name
  project     = var.project
}

resource "cloudstack_instance" "this" {
  for_each = var.instances

  name             = each.value.name
  display_name     = each.value.display_name != null ? each.value.display_name : each.value.name
  service_offering = each.value.service_offering != null ? each.value.service_offering : var.default_service_offering
  template         = each.value.template != null ? each.value.template : var.default_template
  zone             = var.zone
  network_id       = each.value.network_id != null ? each.value.network_id : var.default_network_id
  ip_address       = each.value.ip_address
  root_disk_size   = each.value.root_disk_size
  group            = each.value.group
  keypair          = each.value.keypair != null ? each.value.keypair : local.ssh_keypair_name
  user_data        = each.value.user_data
  start_vm         = each.value.start_vm
  project          = var.project
  tags             = merge(var.tags, each.value.tags)

  affinity_group_ids = [
    for key in each.value.affinity_group_keys :
    cloudstack_affinity_group.this[key].id
  ]

  lifecycle {
    precondition {
      condition     = each.value.network_id != null || var.default_network_id != null
      error_message = "Instance '${each.key}' has no network_id. Set var.default_network_id or instances[\"${each.key}\"].network_id."
    }
  }

  depends_on = [cloudstack_ssh_keypair.this]
}

resource "cloudstack_disk" "this" {
  for_each = local.data_disks

  name               = each.value.name
  attach             = true
  disk_offering      = each.value.disk_offering
  size               = each.value.size
  shrink_ok          = each.value.shrink_ok
  device_id          = each.value.device_id
  virtual_machine_id = cloudstack_instance.this[each.value.instance_key].id
  zone               = var.zone
  project            = var.project
}
