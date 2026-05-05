output "cluster" {
  description = "Kubernetes cluster details."
  value = {
    id                 = cloudstack_kubernetes_cluster.this.id
    name               = cloudstack_kubernetes_cluster.this.name
    state              = cloudstack_kubernetes_cluster.this.state
    ip_address         = cloudstack_kubernetes_cluster.this.ip_address
    zone               = var.zone
    kubernetes_version = var.kubernetes_version
    service_offering   = var.service_offering
    worker_count       = var.worker_count
    control_nodes_size = var.control_plane_count
    etcd_nodes_size    = var.etcd_count
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

output "zcp_defaults" {
  description = "ZCP CKS defaults this module is designed around."
  value       = local.zcp_defaults
}
