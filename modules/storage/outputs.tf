output "volumes" {
  description = "Created data volume details keyed by input key."
  value = {
    for key, volume in cloudstack_disk.this : key => {
      id            = volume.id
      name          = volume.name
      disk_offering = volume.disk_offering
      attached      = try(volume.attached, null)
      instance_id   = try(volume.virtual_machine_id, null)
    }
  }
}

output "volume_ids" {
  description = "All module-managed volume IDs keyed by input key."
  value       = local.managed_volume_ids
}

output "restored_volumes" {
  description = "Snapshot restore requests keyed by input key. Run output in CloudMonkey/CloudStack to get concrete restored volume IDs."
  value = {
    for key, request in terraform_data.snapshot_restore : key => {
      id               = request.id
      name             = request.input.name
      snapshot_id      = request.input.snapshot_id
      disk_offering_id = request.input.disk_offering_id
      zone_id          = request.input.zone_id
    }
  }
}

output "snapshot_policies" {
  description = "Snapshot policy details keyed by input key."
  value = {
    for key, policy in cloudstack_snapshot_policy.this : key => {
      id            = policy.id
      volume_id     = local.snapshot_policy_volume_ids[key]
      schedule      = policy.schedule
      interval_type = policy.interval_type
      max_snaps     = policy.max_snaps
      timezone      = policy.timezone
    }
  }
}

output "snapshot_ids" {
  description = "Snapshot policy IDs keyed by input key. CloudStack creates concrete snapshot object IDs from these policies on schedule."
  value = {
    for key, policy in cloudstack_snapshot_policy.this : key => policy.id
  }
}

output "zcp_offerings" {
  description = "ZCP disk offering names this module is designed to consume."
  value       = local.zcp_offerings
}
