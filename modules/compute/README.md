# CloudStack Compute Module

Creates reusable ZCP compute resources with the Apache CloudStack Terraform
provider.

The module is scoped to one logical instance group per module call. Root
stacks can compose multiple groups (e.g. web tier, app tier, db tier) by
calling this module with `for_each`.

## Resources

| Resource                   | Purpose                                                |
| -------------------------- | ------------------------------------------------------ |
| `cloudstack_instance`      | Creates VMs from a map of instance definitions         |
| `cloudstack_ssh_keypair`   | Optional SSH keypair registered from `ssh_public_key`  |
| `cloudstack_affinity_group`| Optional affinity groups referenced by instance keys   |
| `cloudstack_disk`          | Optional data disks declared inline on each instance   |

## ZCP Service Offerings

ZCP exposes a fixed set of VM offerings (`Nano`, `Starter`, `Basic`,
`Standard`, `Pro`, `Enterprise`). The module accepts offering names as plain
strings and does not validate them, so new offerings work without a module
release. Pass the canonical name in `default_service_offering` or per
instance.

## SSH Keypair

When `create_ssh_keypair` is false and `ssh_keypair_name` is null, instances
launch with no module-injected key. Use this only with templates that bake in
their own credentials or provide access via `user_data`.

## Data Disks

Data disks declared inline are created and attached at instance create time.
Standalone or shared volumes belong in the future `storage` module.

## Networking

The module attaches each instance to a single network. Pass a network ID
from the `networking` module's `network_ids` output as `default_network_id`,
or override per instance.

## Usage

```hcl
module "web" {
  source = "../../modules/compute"

  zone                     = "yow-1"
  project                  = "demo"
  default_service_offering = "Basic"
  default_template         = "Ubuntu 22.04"
  default_network_id       = module.networking["demo"].network_ids["web"]

  create_ssh_keypair = true
  ssh_keypair_name   = "demo-key"
  ssh_public_key     = file("~/.ssh/id_ed25519.pub")

  affinity_groups = {
    spread = {
      name = "web-spread"
      type = "host anti-affinity"
    }
  }

  instances = {
    web1 = {
      name                = "web-01"
      affinity_group_keys = ["spread"]
    }
    web2 = {
      name                = "web-02"
      service_offering    = "Standard"
      affinity_group_keys = ["spread"]
      data_disks = {
        cache = {
          disk_offering = "Custom"
          size          = 50
        }
      }
    }
  }
}
```

See `examples/demo-stack` for the combined demo stack example.
