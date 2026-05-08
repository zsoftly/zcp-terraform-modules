# CloudStack Demo Stack

Combined Terraform example for ZCP customer/demo environments.

This stack composes the networking, load balancing/security, storage, and
Kubernetes modules. Add compute, VPN, and image/template modules here as they
are built.

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

## Storage

Storage is disabled by default. Set `storage_stacks` to create data volumes,
optionally attach them to existing instance IDs, and add scheduled snapshot
policies.

The storage module is designed for the repo-backed ZCP disk offerings:

| Disk offering     | Default size |
| ----------------- | ------------ |
| `Starter-NVMe`    | 50 GB        |
| `Basic-NVMe`      | 90 GB        |
| `Standard-NVMe`   | 180 GB       |
| `Pro-NVMe`        | 360 GB       |
| `Enterprise-NVMe` | 720 GB       |

Use `restored_volumes` to request a new volume from an existing CloudStack
snapshot ID through CloudMonkey.

Immediate one-off snapshots should be created with CloudMonkey or the
CloudStack API, then restored through this stack by passing the resulting
snapshot ID to `restored_volumes`.

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

For ZCP defaults, do not wire CKS to the demo VPC tier network. The current ZCP
CKS model uses an isolated network with source NAT, and the platform lifecycle
test creates its own isolated network. If `network_id` is supplied, it must
refer to a supported CKS isolated network, not the example `VPC Tier` network.

Terraform creates the CKS resource only. A usable ZCP cluster still needs the
post-create platform integration steps from the IaaS automation:

- `546-cks-fix-ccm.yml` for the CCM API endpoint
- `547-cks-storage.yml` for persistent storage

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
