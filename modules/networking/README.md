# CloudStack Networking Module

Creates reusable Apache CloudStack networking resources with the CloudStack
Terraform provider.

The module is scoped to one VPC per module call. Root stacks can compose one or
more VPCs by calling this module with `for_each`.

## Resources

| Resource                      | Purpose                                                 |
| ----------------------------- | ------------------------------------------------------- |
| `cloudstack_vpc`              | Creates a VPC with a configurable CIDR and VPC offering |
| `cloudstack_network`          | Creates isolated/shared networks or VPC tiers           |
| `cloudstack_network_acl`      | Creates optional ACL lists for VPC tiers                |
| `cloudstack_network_acl_rule` | Creates optional ACL rules                              |

## ACS Offering Alignment

This module keeps offering names as inputs so it can be reused across prd,
nonprd, demo, and customer stacks.

| Offering type    | ACS names                                                           |
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
  zone         = "your-zone-name"
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

## Stack Access — Required ACL Rules

When deploying application stacks into a VPC tier, the network ACL must
explicitly allow inbound SSH and all outbound traffic. By default VPC tiers deny
all traffic.

```hcl
network_acls = {
  stacks = {
    name = "stacks-acl"
    rules = [
      {
        rule_number  = 100
        protocol     = "tcp"
        port         = "22"
        cidr_list    = ["0.0.0.0/0"]
        traffic_type = "ingress"
      },
      {
        rule_number  = 200
        protocol     = "all"
        cidr_list    = ["0.0.0.0/0"]
        traffic_type = "egress"
      }
    ]
  }
}
```

Add additional ingress rules per stack as needed. For example, port 80/443 for
web stacks, port 25565 for Minecraft, port 443 for Pritunl. See
`examples/test-images-templates` for a complete working reference.
