# Kubernetes Module

Creates a CloudStack Kubernetes Service (CKS) cluster for ZCP demo and customer
enablement stacks.

The module is scoped to one CKS cluster per module call. Root stacks can compose
multiple clusters with `for_each`, and can pass network IDs from the networking
module when a cluster should be placed on a specific network.

## Features

- CKS cluster creation
- configurable Kubernetes version
- configurable control plane and worker counts
- worker scaling by changing `worker_count`
- optional autoscaling bounds
- optional role-based node offerings and templates
- optional network, project, account, keypair, and CNI configuration
- outputs for cluster ID, state, and API endpoint/IP

## ZCP Defaults

The current ZCP CKS defaults from the IaaS automation are:

- Kubernetes version: `1.34.3`
- CKS network offering: `Isolated Network with Source NAT`
- CKS non-prod node offering: `CKS Node - Intel nonprd`
- CSI disk offering: `Custom-Disk`
- node root disk size: `25` GB
- minimum supported node size: `2` CPU / `4096` MB

The CKS service, supported Kubernetes versions, and CKS ISOs must already be
registered in CloudStack before this module can create clusters.

## Usage

```hcl
module "kubernetes" {
  source = "../../modules/kubernetes"

  name               = "demo-cks-01"
  zone               = "yow-1"
  kubernetes_version = "1.34.3"
  service_offering   = "CKS Node - Intel nonprd"

  worker_count        = 2
  control_plane_count = 1
  node_root_disk_size = 25

  network_id = module.networking["demo"].network_ids["web"]
}
```

## Kubeconfig

The CloudStack API supports kubeconfig retrieval with
`getKubernetesClusterConfig`, but the Terraform provider resource does not
currently expose kubeconfig as an output attribute. This module outputs the
cluster ID and API endpoint/IP. Retrieve kubeconfig after creation with
CloudMonkey:

```bash
cmk -p localadmin get kubernetesClusterConfig id=<cluster-id> \
  | jq -r '.clusterconfig.configdata' > kubeconfig
```

Use `terraform output kubernetes_clusters` from the demo stack to get the
cluster ID.

## Inputs

| Name | Description | Default |
| ---- | ----------- | ------- |
| `name` | CKS cluster name | n/a |
| `zone` | CloudStack zone name or ID | n/a |
| `kubernetes_version` | Registered Kubernetes semantic version | `1.34.3` |
| `service_offering` | Default node service offering | n/a |
| `worker_count` | Worker node count | `1` |
| `control_plane_count` | Control plane node count | `1` |
| `etcd_count` | Dedicated etcd node count | `0` |
| `node_root_disk_size` | Node root disk size in GB | `25` |
| `network_id` | Optional CloudStack network ID | `null` |
| `node_offerings` | Optional service offerings by role | `{}` |
| `node_templates` | Optional templates by role | `{}` |
| `autoscaling_enabled` | Enable worker autoscaling | `false` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `cluster` | Cluster details |
| `cluster_id` | Cluster ID |
| `cluster_state` | Cluster state |
| `api_endpoint` | API endpoint/IP exposed by CloudStack |
| `zcp_defaults` | ZCP defaults used as module guidance |
