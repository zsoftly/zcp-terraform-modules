# CloudStack Storage Module

Creates reusable ZCP block storage resources with the Apache CloudStack
Terraform provider.

The module is scoped to data volumes and scheduled snapshot policy management.
Root stacks can attach volumes to instances created elsewhere by passing the
target VM ID.

## Resources

| Resource                     | Purpose                                                        |
| ---------------------------- | -------------------------------------------------------------- |
| `cloudstack_disk`            | Creates data volumes and can attach them to instances          |
| `cloudstack_snapshot_policy` | Creates scheduled CloudStack volume snapshots                  |
| `terraform_data`             | Runs CloudMonkey restore requests from existing snapshot IDs   |

## Snapshot Model

Snapshot creation is implemented as CloudStack snapshot policies. That keeps the
module declarative and reusable: Terraform manages the desired schedule and
retention, while CloudStack creates concrete snapshots when the policy runs.

Immediate one-off snapshots are operational actions. Create those with
CloudMonkey or the CloudStack API, then pass the resulting snapshot ID to
`restored_volumes` when Terraform should restore it.

## ZCP Offering Alignment

This module keeps disk offering names as inputs so it can be reused across prd,
nonprd, demo, and customer stacks.

| Disk offering     | Default size |
| ----------------- | ------------ |
| `Starter-NVMe`    | 50 GB        |
| `Basic-NVMe`      | 90 GB        |
| `Standard-NVMe`   | 180 GB       |
| `Pro-NVMe`        | 360 GB       |
| `Enterprise-NVMe` | 720 GB       |

Set `size_gb` only when the selected disk offering supports custom sizing.

## Usage

```hcl
module "storage" {
  source = "../../modules/storage"

  zone    = "yow-1"
  project = null

  volumes = {
    app_data = {
      name          = "demo-app-data-01"
      disk_offering = "Starter-NVMe"
      attach        = true
      instance_id   = "replace-with-vm-id"
    }
  }

  snapshot_policies = {
    app_data_daily = {
      volume_key    = "app_data"
      schedule      = "02:00"
      interval_type = "DAILY"
      max_snaps     = 7
      timezone      = "UTC"
    }
  }
}
```

## Restoring From A Snapshot

The CloudStack Terraform provider does not expose a native snapshot restore
resource. This module supports restore requests with CloudMonkey through
`restored_volumes`, because snapshot restore is an operational CloudStack action
that creates a new volume from an existing snapshot ID.

```hcl
module "storage_restore" {
  source = "../../modules/storage"

  zone = "yow-1"

  restored_volumes = {
    app_data_restore = {
      name             = "demo-app-data-restore-01"
      snapshot_id      = "replace-with-snapshot-id"
      disk_offering_id = "replace-with-disk-offering-id"
      zone_id          = "replace-with-zone-id"
    }
  }
}
```

See `infra/terraform/cloudstack/examples/demo-stack` for the combined demo
stack example.
