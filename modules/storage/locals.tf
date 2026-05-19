locals {
  managed_volume_ids = {
    for key, volume in cloudstack_disk.this : key => volume.id
  }

  snapshot_policy_volume_ids = {
    for key, policy in var.snapshot_policies :
    key => try(policy.volume_id, null) != null ? policy.volume_id : local.managed_volume_ids[policy.volume_key]
  }

  zcp_offerings = {
    disk = {
      starter_nvme    = "Starter-NVMe"
      basic_nvme      = "Basic-NVMe"
      standard_nvme   = "Standard-NVMe"
      pro_nvme        = "Pro-NVMe"
      enterprise_nvme = "Enterprise-NVMe"
    }
  }
}
