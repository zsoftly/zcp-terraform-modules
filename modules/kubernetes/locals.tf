locals {
  zcp_defaults = {
    kubernetes_version = "1.34.3"
    network_offering   = "Isolated Network with Source NAT"
    service_offering   = "CKS Node - Intel nonprd"
    csi_disk_offering  = "Custom-Disk"
    node_root_disk_gb  = 25
    min_cpu            = 2
    min_memory_mb      = 4096
  }

  node_offerings = {
    for role, offering in var.node_offerings : role => offering
    if offering != null
  }

  node_templates = {
    for role, template in var.node_templates : role => template
    if template != null
  }
}
