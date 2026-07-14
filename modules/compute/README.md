# CloudStack Compute Module

Creates Apache CloudStack compute resources via the CloudStack Terraform
provider. One module call manages one logical instance group; compose multiple
groups (e.g. web/app/db tiers) by calling the module with `for_each`.

## Resources

| Resource                    | Purpose                                           |
| --------------------------- | ------------------------------------------------- |
| `cloudstack_instance`       | VMs from a map of instance definitions            |
| `cloudstack_ssh_keypair`    | Optional keypair registered from `ssh_public_key` |
| `cloudstack_affinity_group` | Optional groups referenced by instance keys       |
| `cloudstack_disk`           | Optional data disks declared inline per instance  |

## Notes

- **Service offerings** are passed as plain names (e.g. `small-offering`,
  `large-offering`) and not validated by the module — new offerings work without
  a module release.
- **SSH keypair** is opt-in. With `create_ssh_keypair = false` and
  `ssh_keypair_name = null`, instances launch without a module-injected key; use
  only with templates that bake in credentials or accept `user_data`.
- **Networking**: each instance attaches to a single network. Pass a network ID
  from the `networking` module's `network_ids` output as `default_network_id`,
  or override per instance.
- **Data disks** declared inline are created and attached at instance create
  time. Standalone/shared volumes will live in a future `storage` module.

## Usage

```hcl
module "web" {
  source = "../../modules/compute"

  zone                     = "your-zone-name"
  default_service_offering = "your-service-offering"
  default_template         = "Ubuntu-24.04-LTS"
  default_network_id       = module.networking["demo"].network_ids["web"]

  create_ssh_keypair = true
  ssh_keypair_name   = "demo-key"
  ssh_public_key     = file("~/.ssh/id_ed25519.pub")

  instances = {
    web1 = { name = "web-01" }
    web2 = { name = "web-02", service_offering = "your-large-offering" }
  }
}
```

See `examples/demo-stack` for a full example combining `networking` + `compute`.

---

## QA / Test Guide

This section is for verifying the module end-to-end against a real CloudStack
zone.

QA runs against the `examples/demo-stack` root, which wires this module together
with the `networking` module. The demo root selects the network via
`compute_groups[*].vpc_key` + `network_key` (not `default_network_id` directly);
use the module directly only if you need to attach to an existing, pre-created
network.

### 1. Prerequisites

- Terraform `>= 1.5`
- CloudStack API access (URL, API key, secret key) for the target zone
- (Optional) [CloudMonkey](https://github.com/apache/cloudstack-cloudmonkey) for
  out-of-band verification

### 2. Setup

```bash
cd examples/demo-stack
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:

- `cloudstack_api_url`, `cloudstack_api_key`, `cloudstack_secret_key`
- `zone` (your CloudStack zone name or ID)
- `networking_vpcs` and `compute_groups` per the example block

Then:

```bash
terraform init
terraform validate
terraform plan
```

`plan` should show the VPC, network, ACL, keypair, and instance resources to be
created. Confirm the counts match expectations before applying.

### 3. Positive test cases

| #   | Case                           | How to test                                                    | Pass criteria                                                                    |
| --- | ------------------------------ | -------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| 1   | Single instance, defaults      | One entry in `instances`, only `name` set                      | VM reaches `Running` state; outputs include `instance_ids` and `instance_ips`    |
| 2   | Per-instance offering override | `service_offering = "your-large-offering"` on one instance     | That VM has 1 vCPU / 2 GB; siblings use the default                              |
| 3   | SSH keypair created            | `create_ssh_keypair = true` + valid `ssh_public_key`           | `ssh_keypair` output non-null; key visible in CloudStack UI                      |
| 4   | Inline data disk               | Add a `data_disks` block on one instance                       | Disk attached; visible in `compute_data_disks` output and CloudStack volume list |
| 5   | Affinity group                 | Define `affinity_groups` + reference via `affinity_group_keys` | Group created; VM is a member                                                    |
| 6   | Multi-instance, mixed configs  | 2+ instances with different offerings and tags                 | All reach `Running`; tags applied per-instance                                   |
| 7   | Destroy                        | `terraform destroy`                                            | All module-created resources removed; pre-existing resources untouched           |

### 4. Negative test cases

All cases below are reproducible from `examples/demo-stack/terraform.tfvars`
unless noted otherwise.

| #   | Case                        | How to test                                                                            | Expected error                                                         |
| --- | --------------------------- | -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| 1   | Empty instances map         | `compute_groups.web.instances = {}`                                                    | Validation: "At least one instance must be defined."                   |
| 2   | Invalid service offering    | `default_service_offering = "DoesNotExist"`                                            | Apply error: "Error retrieving ID of service_offering"                 |
| 3   | Invalid template            | `default_template = "DoesNotExist"`                                                    | Apply error: "Error retrieving ID of template"                         |
| 4   | Bad `vpc_key`               | `compute_groups.web.vpc_key = "no-such-vpc"`                                           | Plan-time precondition: "vpc_key = \"no-such-vpc\" not found ..."      |
| 5   | Bad `network_key`           | `compute_groups.web.network_key = "no-such-tier"` (with a valid `vpc_key`)             | Plan-time precondition: "network_key = \"no-such-tier\" not found ..." |
| 6   | Host-tag/capacity mismatch  | Use an offering whose `hosttags` has no matching host capacity in the target zone      | `errorcode 530`, "Unable to create a deployment"                       |
| 7   | Wrong network UUID (direct) | Call the module directly (not via demo-stack) with a non-existent `default_network_id` | Apply error from CloudStack on instance create                         |

### 5. Out-of-band verification (CloudMonkey)

```bash
# Confirm VM state matches Terraform state
cmk list virtualmachines name=<instance-name> filter=id,name,state,serviceofferingname,templatename,hypervisor

# Confirm SSH keypair was registered
cmk list sshkeypairs name=<keypair-name>

# Confirm data disks
cmk list volumes virtualmachineid=<vm-uuid> filter=name,size,type,state
```

### 6. Cleanup

```bash
terraform destroy
```

Then verify in the CloudStack UI (or via `cmk list virtualmachines`) that no
test resources remain. If a VM is stuck in `Error` state from a failed apply,
clear it manually before retrying:

```bash
cmk destroy virtualmachine id=<vm-uuid> expunge=true
terraform state rm '<resource-address>'
```

### 7. Sign-off checklist

- [ ] `terraform validate` passes
- [ ] `terraform plan` matches expected resource counts
- [ ] All positive cases produce `Running` instances
- [ ] All negative cases fail with the expected error
- [ ] Outputs (`instance_ids`, `instance_ips`, `ssh_keypair`, `data_disks`)
      populated correctly
- [ ] `terraform destroy` removes everything the module created
