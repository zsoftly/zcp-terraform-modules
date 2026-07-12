# CloudStack Storage Module

Creates reusable Apache CloudStack block storage resources with the CloudStack
Terraform provider.

The module is scoped to data volumes and scheduled snapshot policy management.
Root stacks can attach volumes to instances created elsewhere by passing the
target VM ID.

## Resources

| Resource                     | Purpose                                             |
| ---------------------------- | --------------------------------------------------- |
| `cloudstack_disk`            | Creates data volumes and attaches them to instances |
| `cloudstack_snapshot_policy` | Creates scheduled CloudStack volume snapshots       |

## Snapshot Model

Snapshot creation is implemented as CloudStack snapshot policies. That keeps the
module declarative and reusable: Terraform manages the desired schedule and
retention, while CloudStack creates concrete snapshots when the policy runs.

Immediate one-off snapshots are operational actions. Create those with
CloudMonkey or the CloudStack API, then pass the resulting snapshot ID to
`restored_volumes` when Terraform should restore it.

## ACS Offering Alignment

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
resource, and a `local-exec` restore cannot return the created volume ID to
Terraform state. Restores must be performed as a manual operational step:

```bash
cmk -p <profile> create volume \
  name=<name> \
  zoneid=<zone-id> \
  diskofferingid=<disk-offering-id> \
  snapshotid=<snapshot-id>
```

Once restored, the resulting volume ID can be passed to `snapshot_policies` via
`volume_id` for policy management.

See `examples/demo-stack` for the combined demo stack example.
