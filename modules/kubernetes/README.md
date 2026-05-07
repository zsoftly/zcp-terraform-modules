# Kubernetes Module

Creates a CloudStack Kubernetes Service (CKS) cluster for ZCP demo and customer
enablement stacks.

The module is scoped to one CKS cluster per module call. Root stacks can compose
multiple clusters with `for_each`, and can pass a supported CKS network ID when
a cluster should be placed on a specific isolated network.

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

For ZCP defaults, `network_id` must refer to a supported CKS isolated network.
Do not use the demo VPC tier network as the CKS network. The current ZCP CKS
lifecycle creates its own isolated network with source NAT.

Terraform only creates the CKS resource. A usable ZCP cluster still needs the
post-create platform integration steps from the IaaS automation:

- `546-cks-fix-ccm.yml` for the CCM API endpoint
- `547-cks-storage.yml` for persistent storage

Expose the Terraform outputs from this module, then pass the cluster ID/API
details to the follow-up automation.

## Update Behavior

Changing `worker_count` is the intended worker scaling path. Other cluster
shape inputs can recreate the cluster depending on the CloudStack provider and
API behavior, including `control_plane_count`, `etcd_count`, `network_id`,
`keypair`, `hypervisor`, `node_templates`, and `node_offerings`. Review the
Terraform plan before applying those changes.

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

  # Optional: set only when this is a supported CKS isolated network.
  network_id = "isolated-cks-network-id"
}
```

## Kubeconfig

The CloudStack API supports kubeconfig retrieval with
`getKubernetesClusterConfig`, but the Terraform provider resource does not
currently expose kubeconfig as an output attribute. This module outputs the
cluster ID and API endpoint/IP. Retrieve kubeconfig after creation with
CloudMonkey:

```bash
cmk -p <profile> get kubernetesClusterConfig id=<cluster-id> \
  | jq -r '.clusterconfig.configdata' > kubeconfig
```

Use `terraform output kubernetes_clusters` from the demo stack to get the
cluster ID.

## Inputs

| Name | Description | Default |
| ---- | ----------- | ------- |
| `name` | CKS cluster name | n/a |
| `description` | Optional cluster description | `null` |
| `zone` | CloudStack zone name or ID | n/a |
| `kubernetes_version` | Registered Kubernetes semantic version | `1.34.3` |
| `service_offering` | Default node service offering | n/a |
| `worker_count` | Worker node count | `1` |
| `control_plane_count` | Control plane node count | `1` |
| `etcd_count` | Dedicated etcd node count | `0` |
| `node_root_disk_size` | Node root disk size in GB | `25` |
| `node_offerings` | Optional service offerings by role | `{}` |
| `node_templates` | Optional templates by role | `{}` |
| `autoscaling_enabled` | Enable worker autoscaling | `false` |
| `autoscaling_min_size` | Minimum worker count when autoscaling is enabled | `null` |
| `autoscaling_max_size` | Maximum worker count when autoscaling is enabled | `null` |
| `network_id` | Optional supported CKS isolated network ID | `null` |
| `keypair` | Optional SSH keypair for nodes | `null` |
| `hypervisor` | Hypervisor used for CKS nodes | `KVM` |
| `cni_configuration_id` | Optional CloudStack CNI configuration ID | `null` |
| `cni_config_details` | Optional CNI configuration parameter map | `null` |
| `project` | Optional CloudStack project name or ID | `null` |
| `domain_id` | Optional CloudStack domain ID | `null` |
| `account` | Optional CloudStack account name | `null` |
| `docker_registry_url` | Optional private Docker registry URL | `null` |
| `docker_registry_username` | Optional private Docker registry username | `null` |
| `docker_registry_password` | Optional private Docker registry password | `null` |

## Outputs

| Name | Description |
| ---- | ----------- |
| `cluster` | Cluster details |
| `cluster_id` | Cluster ID |
| `cluster_state` | Cluster state |
| `api_endpoint` | API endpoint/IP exposed by CloudStack |
| `zcp_defaults` | ZCP defaults used as module guidance |
