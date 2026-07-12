# v1.0.0 Release Notes

Initial public release of the Apache CloudStack Terraform modules by ZSoftly.

## What Is Included

9 reusable Terraform modules covering the full Apache CloudStack (ACS)
provisioning surface:

| Module                    | Purpose                                                             |
| ------------------------- | ------------------------------------------------------------------- |
| `networking`              | VPCs, VPC tiers/networks, IP ranges, and ACLs                       |
| `compute`                 | Instances, SSH keypairs, affinity groups, data disks                |
| `load-balancing-security` | Public IPs, firewall rules, NAT, load balancing                     |
| `storage`                 | Volumes, attachments, and snapshot policies                         |
| `kubernetes`              | CKS clusters and node sizing                                        |
| `accounts-projects`       | Domains, accounts, users, roles, projects, quotas                   |
| `vpn-connectivity`        | Site-to-site VPN gateway and connections                            |
| `images-templates`        | Template registration, versioning, and sharing                      |
| `stacks`                  | App stack selection and cloud-init userdata rendering (in progress) |

Two runnable examples:

- `examples/demo-stack` — composable demo stack using all implemented modules
- `examples/test-images-templates` — end-to-end test for the stacks module

Provider: `cloudstack/cloudstack ~> 0.6`. Requires Terraform >= 1.5.

## Installation

Reference a module directly from GitHub using a version tag:

```hcl
module "networking" {
  source = "github.com/zsoftly/zpcp//modules/networking?ref=v1.0.0"

  name         = "prod-vpc-01"
  cidr         = "10.10.0.0/16"
  zone         = "your-zone-name"
  vpc_offering = "Standard VPC offering"

  networks = {
    web = {
      name             = "web-tier"
      cidr             = "10.10.1.0/24"
      network_offering = "VPC Tier"
    }
  }
}
```

Pin to a tag (`?ref=v1.0.0`) rather than the main branch to get reproducible
plans.

## Notes

- The `stacks` module is functional for the `docker` stack. Remaining stacks
  (`cpanel`, `drupal`, `gitlab`, etc.) have cloud-init templates in progress.
- CKS clusters require post-create integration steps for the cloud controller
  manager and persistent storage. The `kubernetes` module output
  `acs_post_create_notes` documents this explicitly.
- Remote access VPN is not supported in CloudStack provider v0.6.x. Use the
  CloudStack UI or API directly until provider support is added.
