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

output "compute_instances" {
  description = "Instance details keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.instances
  }
}

output "compute_instance_ids" {
  description = "Instance IDs keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.instance_ids
  }
}

output "compute_instance_ips" {
  description = "Instance primary IPs keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.instance_ips
  }
}

output "compute_ssh_keypairs" {
  description = "SSH keypair details keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.ssh_keypair
  }
}

output "compute_data_disks" {
  description = "Data disk details keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.data_disks
  }
}

output "compute_affinity_groups" {
  description = "Affinity group details keyed by compute group key."
  value = {
    for key, compute in module.compute : key => compute.affinity_groups
  }
}
