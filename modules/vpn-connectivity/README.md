# CloudStack VPN Connectivity Module

Creates a site-to-site VPN gateway and connections using the Apache CloudStack
Terraform provider.

## Resources

| Resource                          | Purpose                                                      |
| --------------------------------- | ------------------------------------------------------------ |
| `cloudstack_vpn_gateway`          | VPN endpoint attached to a VPC — one per module call         |
| `cloudstack_vpn_customer_gateway` | Remote peer definition (IP, CIDR, PSK, IKE/ESP policy)       |
| `cloudstack_vpn_connection`       | Links a customer gateway to the VPN gateway to form a tunnel |

## Provider Limitation

Remote access VPN (`cloudstack_remote_access_vpn`, `cloudstack_vpn_user`) is not
available in provider v0.6.x. Remote access VPN must be configured directly in
the CloudStack UI or via the CloudStack API outside Terraform until provider
support is added.

## ACS Policy Reference

Common IKE/ESP policy strings are available in `locals.tf`.

| Key                      | Policy string            |
| ------------------------ | ------------------------ |
| `aes256_sha256_modp2048` | `aes256-sha256;modp2048` |
| `aes128_sha1_modp1536`   | `aes128-sha1;modp1536`   |

## Usage

```hcl
module "vpn_connectivity" {
  source = "../../modules/vpn-connectivity"

  vpc_id  = module.networking["prod"].vpc.id
  project = var.project

  customer_gateways = {
    hq = {
      name       = "hq-peer"
      gateway    = "203.0.113.1"
      cidr       = "192.168.1.0/24"
      ipsec_psk  = var.vpn_psk_hq
      esp_policy = "aes256-sha256;modp2048"
      ike_policy = "aes256-sha256;modp2048"
    }
  }
}
```

See `examples/demo-stack` for the combined demo stack example.
