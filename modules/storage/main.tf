resource "cloudstack_disk" "this" {
  for_each = var.volumes

  name               = each.value.name
  disk_offering      = each.value.disk_offering
  size               = try(each.value.size_gb, null)
  zone               = var.zone
  project            = var.project
  attach             = try(each.value.attach, true) && try(each.value.instance_id, null) != null
  virtual_machine_id = try(each.value.instance_id, null)
}

resource "terraform_data" "snapshot_restore" {
  for_each = var.restored_volumes

  input = each.value

  provisioner "local-exec" {
    command = join(" ", compact([
      "cmk",
      var.cloudmonkey_profile != null ? "-p ${var.cloudmonkey_profile}" : "",
      "create volume",
      "name='${each.value.name}'",
      "zoneid='${each.value.zone_id}'",
      "diskofferingid='${each.value.disk_offering_id}'",
      "snapshotid='${each.value.snapshot_id}'",
    ]))
  }
}

resource "cloudstack_snapshot_policy" "this" {
  for_each = var.snapshot_policies

  volume_id     = local.snapshot_policy_volume_ids[each.key]
  schedule      = each.value.schedule
  interval_type = upper(each.value.interval_type)
  max_snaps     = each.value.max_snaps
  timezone      = try(each.value.timezone, var.snapshot_timezone)
}
