# CloudStack Demo Stack

Combined Terraform example for ZCP customer/demo environments.

This stack composes the networking, load balancing/security, and Kubernetes
modules. Add compute, storage, VPN, and image/template modules here as they are
built.

## Networking

The demo stack creates one or more VPCs from the `networking_vpcs` map. Each map
entry calls the reusable networking module once, keeping the child module scoped
to one VPC while the root stack composes multiple VPCs when needed.

The default `networking_vpcs` value creates one non-prod demo VPC using the
repo-backed ZCP offerings:

| Input            | Default                          |
| ---------------- | -------------------------------- |
| VPC offering     | `Standard VPC offering - nonprd` |
| Network offering | `VPC Tier`                       |

## Load Balancing & Security

The demo stack creates one public IP for the web tier, then attaches ingress and
egress firewall rules for HTTP and HTTPS. Static NAT, port forwarding, and load
balancer rules are supported by the child module, but they require VM IDs from a
compute module or existing instances.

## Kubernetes

`kubernetes_clusters` can create one or more CKS clusters. CKS service and
supported Kubernetes versions must already be enabled and registered in
CloudStack before a cluster can be applied.

For ZCP defaults, do not wire CKS to the demo VPC tier network. The current ZCP
CKS model uses an isolated network with source NAT, and the platform lifecycle
test creates its own isolated network. If `network_id` is supplied, it must
refer to a supported CKS isolated network, not the example `VPC Tier` network.

Terraform creates the CKS resource only. A usable ZCP cluster still needs the
post-create platform integration steps from the IaaS automation:

- `546-cks-fix-ccm.yml` for the CCM API endpoint
- `547-cks-storage.yml` for persistent storage

## VPN & Connectivity

Creates a VPN gateway attached to the demo VPC and optional site-to-site
connections from the `vpn_customer_gateways` map.

The default value is an empty map — no customer gateways or connections are
planned by default. Only the VPN gateway is created (one per VPC). To add
site-to-site connections, supply customer gateways via a separate sensitive
`.tfvars` file that is never committed:

```hcl
vpn_customer_gateways = {
  hq = {
    name       = "hq-peer"
    gateway    = "203.0.113.1"
    cidr       = "192.168.1.0/24"
    ipsec_psk  = "supplied-at-runtime"
    esp_policy = "aes256-sha256;modp2048"
    ike_policy = "aes256-sha256;modp2048"
  }
}
```

Provider limitation: Remote access VPN is not supported in CloudStack provider
v0.6.x. Configure it directly in the CloudStack UI or via the CloudStack API
until provider support is added.

See `terraform.tfvars.example` for the full variable structure.

## Dry Run

```bash
cd examples/demo-stack
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

For a real ZCP dry run, copy `terraform.tfvars.example` to `terraform.tfvars`
and replace the CloudStack API values.

```bash
terraform plan
```

Do not run `terraform apply` unless the plan has been reviewed.

## Kubeconfig

The CloudStack Terraform provider exposes cluster ID and endpoint details, but
does not currently expose kubeconfig directly. After a CKS cluster is created,
retrieve kubeconfig with CloudMonkey:

```bash
cmk -p <profile> get kubernetesClusterConfig id=<cluster-id> \
  | jq -r '.clusterconfig.configdata' > kubeconfig
```
