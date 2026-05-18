variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
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
}

