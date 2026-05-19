resource "cloudstack_disk" "this" {
  for_each = var.volumes

  name               = each.value.name
  disk_offering      = each.value.disk_offering
  size               = each.value.size_gb
  zone               = var.zone
  project            = var.project
  attach             = each.value.attach && each.value.instance_id != null
  virtual_machine_id = each.value.instance_id
}

check "snapshot_volume_keys_valid" {
  assert {
    condition = alltrue([
      for key, policy in var.snapshot_policies :
      try(policy.volume_key, null) == null || contains(keys(var.volumes), policy.volume_key)
    ])
    error_message = "snapshot_policies volume_key must reference a key that exists in var.volumes."
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
