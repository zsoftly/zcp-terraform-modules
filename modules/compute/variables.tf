variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string

  validation {
    condition     = var.zone != null && length(trimspace(var.zone)) > 0
    error_message = "zone must not be empty."
  }
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all instances created by this module."
  type        = map(string)
  default     = {}
}

variable "default_service_offering" {
  description = "Service offering used when an instance entry does not specify one."
  type        = string
}

variable "default_template" {
  description = "Template used when an instance entry does not specify one."
  type        = string
}

variable "default_network_id" {
  description = "Network ID attached to instances that do not specify network_id."
  type        = string
  default     = null
}

variable "create_ssh_keypair" {
  description = "Whether to create a CloudStack SSH keypair from ssh_public_key."
  type        = bool
  default     = false
}

variable "ssh_keypair_name" {
  description = "Name of the SSH keypair. Used as the created keypair name when create_ssh_keypair is true, or as a reference to an existing keypair otherwise."
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Public key material registered when create_ssh_keypair is true."
  type        = string
  default     = null
}

variable "affinity_groups" {
  description = "Affinity groups created and referenced by instances via affinity_group_keys."
  type = map(object({
    name        = string
    type        = string
    description = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, ag in var.affinity_groups : contains(["host anti-affinity", "host affinity"], ag.type)])
    error_message = "affinity_groups type must be 'host anti-affinity' or 'host affinity'."
  }
}

variable "instances" {
  description = "Instances to create. Each entry may override defaults and declare inline data disks."
  type = map(object({
    name                = string
    display_name        = optional(string)
    service_offering    = optional(string)
    template            = optional(string)
    network_id          = optional(string)
    ip_address          = optional(string)
    keypair             = optional(string)
    user_data           = optional(string)
    root_disk_size      = optional(number)
    group               = optional(string)
    start_vm            = optional(bool, true)
    affinity_group_keys = optional(list(string), [])
    tags                = optional(map(string), {})
    data_disks = optional(map(object({
      disk_offering = string
      size          = optional(number)
      shrink_ok     = optional(bool, false)
      device_id     = optional(number)
    })), {})
  }))

  validation {
    condition     = length(var.instances) > 0
    error_message = "At least one instance must be defined."
  }

  validation {
    condition     = alltrue([for k, i in var.instances : i.root_disk_size == null || i.root_disk_size >= 10])
    error_message = "Instance root_disk_size must be at least 10 GB when specified."
  }

  validation {
    condition = alltrue(flatten([
      for k, i in var.instances : [
        for dk, disk in i.data_disks :
        disk.device_id == null || (disk.device_id >= 1 && disk.device_id <= 6)
      ]
    ]))
    error_message = "Data disk device_id must be between 1 and 6 when specified."
  }
}

check "ssh_keypair_name_required" {
  assert {
    condition     = !var.create_ssh_keypair || var.ssh_keypair_name != null
    error_message = "ssh_keypair_name is required when create_ssh_keypair is true."
  }
}

check "ssh_public_key_required" {
  assert {
    condition     = !var.create_ssh_keypair || var.ssh_public_key != null
    error_message = "ssh_public_key is required when create_ssh_keypair is true."
  }
}

