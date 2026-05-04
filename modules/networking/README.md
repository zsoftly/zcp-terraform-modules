# CloudStack Networking Module

Creates reusable ZCP networking resources with the Apache CloudStack Terraform provider.

The module is scoped to one VPC per module call. Root stacks can compose one or
more VPCs by calling this module with `for_each`.

## Resources

| Resource                      | Purpose                                                 |
| ----------------------------- | ------------------------------------------------------- |
| `cloudstack_vpc`              | Creates a VPC with a configurable CIDR and VPC offering |
| `cloudstack_network`          | Creates isolated/shared networks or VPC tiers           |
| `cloudstack_network_acl`      | Creates optional ACL lists for VPC tiers                |
| `cloudstack_network_acl_rule` | Creates optional ACL rules                              |

## ZCP Offering Alignment

This module keeps offering names as inputs so it can be reused across prd,
nonprd, demo, and customer stacks.

| Offering type    | ZCP names                                                           |
| ---------------- | ------------------------------------------------------------------- |
| VPC              | `Standard VPC offering`, `Standard VPC offering - nonprd`           |
| VPC tier network | `VPC Tier`                                                          |
| Isolated network | `Isolated Network with Source NAT`, `Isolated Network Console Only` |
| Shared network   | `Shared Network`                                                    |

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  name         = "dev-vpc-01"
  display_text = "Development VPC"
  cidr         = "10.20.0.0/16"
  zone         = "yow-1"
  vpc_offering = "Standard VPC offering - nonprd"

  network_acls = {
    web = {
      name = "dev-web-tier-acl"
      rules = [
        {
          rule_number  = 100
          protocol     = "tcp"
          port         = "443"
          cidr_list    = ["0.0.0.0/0"]
          traffic_type = "ingress"
        }
      ]
    }
  }

  networks = {
    web = {
      name             = "web-tier"
      cidr             = "10.20.1.0/24"
      gateway          = "10.20.1.1"
      startip          = "10.20.1.10"
      endip            = "10.20.1.200"
      network_offering = "VPC Tier"
      acl_key          = "web"
    }
  }
}
```

See `examples/demo-stack` for the combined demo stack example.
