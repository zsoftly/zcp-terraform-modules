output "cluster" {
  description = "Kubernetes cluster details."
  value = {
    id                 = cloudstack_kubernetes_cluster.this.id
    name               = cloudstack_kubernetes_cluster.this.name
    state              = cloudstack_kubernetes_cluster.this.state
    ip_address         = cloudstack_kubernetes_cluster.this.ip_address
    zone               = cloudstack_kubernetes_cluster.this.zone
    kubernetes_version = cloudstack_kubernetes_cluster.this.kubernetes_version
    service_offering   = cloudstack_kubernetes_cluster.this.service_offering
    worker_count       = cloudstack_kubernetes_cluster.this.size
    control_nodes_size = cloudstack_kubernetes_cluster.this.control_nodes_size
    etcd_nodes_size    = cloudstack_kubernetes_cluster.this.etcd_nodes_size
  }
}

output "cluster_id" {
  description = "Kubernetes cluster ID."
  value       = cloudstack_kubernetes_cluster.this.id
}

output "cluster_state" {
  description = "Kubernetes cluster state."
  value       = cloudstack_kubernetes_cluster.this.state
}

output "api_endpoint" {
  description = "Kubernetes API endpoint/IP exposed by CloudStack."
  value       = cloudstack_kubernetes_cluster.this.ip_address
}

output "acs_post_create_notes" {
  description = "Post-create steps required after Terraform provisions the CKS resource."
  value = {
    cluster_ready_after_apply = false
    required_steps = [
      "Configure the cloud controller manager API endpoint",
      "Configure persistent storage (CSI driver)",
    ]
    note = "Terraform creates the CloudStack CKS resource. Complete the post-create platform integration steps before treating the cluster as fully usable. Consult your CloudStack platform runbooks for details."
  }
}

output "acs_defaults" {
  description = "ACS CKS defaults this module is designed around."
  value       = local.acs_defaults
}
