# Load Balancing & Security Module

Creates CloudStack traffic routing and security resources for ZCP customer and
demo environments.

## Resources

This module can manage:

- public IP allocation
- ingress firewall rules
- egress firewall rules
- static NAT mappings
- port forwarding rules
- load balancer rules

The module uses native Apache CloudStack resources. It does not configure
OPNsense or other platform edge devices.

## Usage

```hcl
module "load_balancing_security" {
  source = "../../modules/load-balancing-security"

  name       = "demo-edge"
  zone       = "yow-1"
  project    = null
  network_id = module.networking["demo"].network_ids["web"]

  public_ips = {
    web = {}
  }

  firewalls = {
    web = {
      public_ip_key = "web"
      rules = [
        {
          cidr_list = ["0.0.0.0/0"]
          protocol  = "tcp"
          ports     = ["80", "443"]
        }
      ]
    }
  }

  static_nats = {
    web = {
      public_ip_key      = "web"
      virtual_machine_id = "vm-id"
    }
  }

  port_forwards = {
    ssh = {
      public_ip_key = "web"
      forwards = [
        {
          protocol           = "tcp"
          public_port        = 2222
          private_port       = 22
          virtual_machine_id = "vm-id"
        }
      ]
    }
  }

  load_balancer_rules = {
    https = {
      name          = "demo-https"
      description   = "Demo HTTPS load balancer"
      public_ip_key = "web"
      algorithm     = "roundrobin"
      public_port   = 443
      private_port  = 443
      member_ids    = ["vm-id-1", "vm-id-2"]
    }
  }
}
```

## Inputs

| Name | Description |
| ---- | ----------- |
| `name` | Logical name for this traffic and security configuration. |
| `zone` | CloudStack zone name or ID. |
| `project` | Optional CloudStack project name or ID. |
| `network_id` | Default network ID for public IPs, egress rules, and VPC LB rules. |
| `vpc_id` | Optional default VPC ID for public IP allocation. |
| `existing_public_ip_ids` | Existing public IP IDs that can be referenced by key. |
| `public_ips` | Public IPs to acquire. |
| `firewalls` | Ingress firewall rule sets. |
| `egress_firewalls` | Egress firewall rule sets. |
| `static_nats` | Static NAT mappings. |
| `port_forwards` | Port forwarding rule sets. |
| `load_balancer_rules` | Load balancer rules and VM members. |

## Outputs

| Name | Description |
| ---- | ----------- |
| `public_ips` | Allocated public IP IDs and addresses. |
| `public_ip_ids` | Allocated and existing public IP IDs known to the module. |
| `firewall_rule_sets` | Ingress firewall resource IDs. |
| `egress_firewall_rule_sets` | Egress firewall resource IDs. |
| `static_nats` | Static NAT resource IDs. |
| `port_forwards` | Port forwarding resource IDs. |
| `load_balancer_rules` | Load balancer rule IDs. |
