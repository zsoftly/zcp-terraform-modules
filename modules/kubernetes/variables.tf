variable "name" {
  description = "Name of the CloudStack Kubernetes Service cluster."
  type        = string

  validation {
    condition     = var.name != null && length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "description" {
  description = "Optional description for the Kubernetes cluster."
  type        = string
  default     = null
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
}

variable "kubernetes_version" {
  description = "Registered Kubernetes semantic version to use for the cluster."
  type        = string
  default     = "1.34.3"

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "kubernetes_version must be a semantic version without a leading 'v' (e.g. 1.28.0)."
  }
}

variable "service_offering" {
  description = "Default CloudStack service offering name or ID for cluster nodes."
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes. Changing this scales the worker pool."
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1
    error_message = "worker_count must be at least 1."
  }
}

variable "control_plane_count" {
  description = "Number of control plane nodes."
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 3, 5], var.control_plane_count)
    error_message = "control_plane_count must be 1, 3, or 5."
  }
}

variable "etcd_count" {
  description = "Number of dedicated etcd nodes. Use 0 to run etcd on control plane nodes."
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 3, 5], var.etcd_count)
    error_message = "etcd_count must be 0, 1, 3, or 5."
  }
}

variable "node_root_disk_size" {
  description = "Root disk size in GB for each Kubernetes node."
  type        = number
  default     = 25

  validation {
    condition     = var.node_root_disk_size >= 20
    error_message = "node_root_disk_size must be at least 20 GB."
  }
}

variable "node_offerings" {
  description = "Optional service offerings by node role. Valid keys are control, worker, and etcd."
  type = object({
    control = optional(string)
    worker  = optional(string)
    etcd    = optional(string)
  })
  default = {}
}

variable "node_templates" {
  description = "Optional node templates by node role. Valid keys are control, worker, and etcd."
  type = object({
    control = optional(string)
    worker  = optional(string)
    etcd    = optional(string)
  })
  default = {}
}

variable "autoscaling_enabled" {
  description = "Whether worker node autoscaling is enabled."
  type        = bool
  default     = false
}

variable "autoscaling_min_size" {
  description = "Minimum worker count when autoscaling is enabled."
  type        = number
  default     = null
}

variable "autoscaling_max_size" {
  description = "Maximum worker count when autoscaling is enabled."
  type        = number
  default     = null
}

variable "network_id" {
  description = "Optional CloudStack network ID where the Kubernetes cluster should be deployed."
  type        = string
  default     = null
}

variable "keypair" {
  description = "Optional CloudStack SSH key pair name for cluster nodes."
  type        = string
  default     = null
}

variable "hypervisor" {
  description = "Hypervisor used for CKS nodes."
  type        = string
  default     = "KVM"

  validation {
    condition     = contains(["KVM", "VMware", "XenServer", "BareMetal", "Simulator", "Hyperv", "LXC"], var.hypervisor)
    error_message = "hypervisor must be one of: KVM, VMware, XenServer, BareMetal, Simulator, Hyperv, LXC."
  }
}

variable "cni_configuration_id" {
  description = "Optional CloudStack CNI configuration ID."
  type        = string
  default     = null
}

variable "cni_config_details" {
  description = "Optional CNI configuration parameter substitutions."
  type        = map(string)
  default     = null
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "domain_id" {
  description = "Optional CloudStack domain ID."
  type        = string
  default     = null
}

variable "account" {
  description = "Optional CloudStack account name."
  type        = string
  default     = null
}

variable "docker_registry_url" {
  description = "Optional private Docker registry URL."
  type        = string
  default     = null
}

variable "docker_registry_username" {
  description = "Optional private Docker registry username."
  type        = string
  default     = null
}

variable "docker_registry_password" {
  description = "Optional private Docker registry password."
  type        = string
  default     = null
  sensitive   = true
}

check "autoscaling_bounds_required" {
  assert {
    condition = (
      !var.autoscaling_enabled ||
      (
        var.autoscaling_min_size != null &&
        var.autoscaling_max_size != null &&
        var.autoscaling_min_size <= var.autoscaling_max_size &&
        var.worker_count >= var.autoscaling_min_size &&
        var.worker_count <= var.autoscaling_max_size
      )
    )
    error_message = "autoscaling_min_size and autoscaling_max_size are required when autoscaling_enabled is true, min must be less than or equal to max, and worker_count must be within the min/max range."
  }
}

check "project_or_account_scope" {
  assert {
    condition     = !(var.project != null && var.account != null)
    error_message = "Set either project or account scope, not both. domain_id may be used with either when required by CloudStack."
  }
}

check "account_requires_domain_id" {
  assert {
    condition     = var.account == null || var.domain_id != null
    error_message = "domain_id is required when account is set."
  }
}

check "docker_registry_credentials_complete" {
  assert {
    condition = (
      (
        var.docker_registry_url == null &&
        var.docker_registry_username == null &&
        nonsensitive(var.docker_registry_password) == null
      ) ||
      (
        var.docker_registry_url != null &&
        var.docker_registry_username != null &&
        nonsensitive(var.docker_registry_password) != null
      )
    )
    error_message = "Docker registry credentials must be provided as a complete set: docker_registry_url, docker_registry_username, and docker_registry_password."
  }
}
