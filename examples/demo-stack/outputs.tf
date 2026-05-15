output "vpcs" {
  description = "VPC details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.vpc
  }
}

output "network_acls" {
  description = "Network ACL details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_acls
  }
}

output "networks" {
  description = "Network details keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.networks
  }
}

output "network_ids" {
  description = "Network IDs keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_ids
  }
}

output "network_cidrs" {
  description = "Network CIDRs keyed by input VPC key."
  value = {
    for key, networking in module.networking : key => networking.network_cidrs
  }
}

output "public_ips" {
  description = "Public IP details keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.public_ips
  }
}

output "firewall_rule_sets" {
  description = "Ingress firewall resources keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.firewall_rule_sets
  }
}

output "egress_firewall_rule_sets" {
  description = "Egress firewall resources keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.egress_firewall_rule_sets
  }
}

output "static_nats" {
  description = "Static NAT resources keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.static_nats
  }
}

output "port_forwards" {
  description = "Port forwarding resources keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.port_forwards
  }
}

output "load_balancer_rules" {
  description = "Load balancer rules keyed by load balancing/security stack key."
  value = {
    for key, stack in module.load_balancing_security : key => stack.load_balancer_rules
  }
}

output "storage_volumes" {
  description = "Storage volume details keyed by storage stack key."
  value = {
    for key, storage in module.storage : key => storage.volumes
  }
}

output "storage_volume_ids" {
  description = "Storage volume IDs keyed by storage stack key."
  value = {
    for key, storage in module.storage : key => storage.volume_ids
  }
}

output "storage_restored_volumes" {
  description = "Restored storage volume details keyed by storage stack key."
  value = {
    for key, storage in module.storage : key => storage.restored_volumes
  }
}

output "storage_snapshot_policies" {
  description = "Storage snapshot policy details keyed by storage stack key."
  value = {
    for key, storage in module.storage : key => storage.snapshot_policies
  }
}

output "storage_snapshot_ids" {
  description = "Storage snapshot policy IDs keyed by storage stack key."
  value = {
    for key, storage in module.storage : key => storage.snapshot_ids
  }
}

output "kubernetes_clusters" {
  description = "Kubernetes cluster details keyed by input cluster key."
  value = {
    for key, kubernetes in module.kubernetes : key => kubernetes.cluster
  }
}

output "kubernetes_api_endpoints" {
  description = "Kubernetes API endpoint/IP values keyed by input cluster key."
  value = {
    for key, kubernetes in module.kubernetes : key => kubernetes.api_endpoint
  }
}

output "kubernetes_post_create_automation" {
  description = "ZCP post-create automation requirements keyed by input cluster key."
  value = {
    for key, kubernetes in module.kubernetes : key => kubernetes.zcp_post_create_automation
  }
}

output "account_ids" {
  description = "Account IDs keyed by account key."
  value       = module.accounts_projects.account_ids
}

output "project_ids" {
  description = "Project IDs keyed by project key."
  value       = module.accounts_projects.project_ids
}

output "roles" {
  description = "Role details keyed by role key."
  value       = module.accounts_projects.roles
}

output "domain_ids" {
  description = "Domain IDs keyed by domain key."
  value       = module.accounts_projects.domain_ids
}

output "vpn_gateway" {
  description = "VPN gateway details for the demo VPC."
  value       = module.vpn_connectivity.vpn_gateway
}

output "vpn_customer_gateway_ids" {
  description = "Customer gateway IDs keyed by input key."
  value       = module.vpn_connectivity.customer_gateway_ids
}

output "vpn_connection_ids" {
  description = "VPN connection IDs keyed by input key."
  value       = module.vpn_connectivity.connection_ids
}
