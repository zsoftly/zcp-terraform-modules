variable "zone" {
  description = "CloudStack zone name or ID where volumes are created."
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

variable "volumes" {
  description = "Data volumes to create, optionally attached to an existing instance."
  type = map(object({
    name          = string
    disk_offering = string
    size_gb       = optional(number)
    attach        = optional(bool, true)
    instance_id   = optional(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.volumes : v.size_gb == null || v.size_gb >= 1])
    error_message = "Volume size_gb must be at least 1 GB when specified."
  }
}

variable "snapshot_timezone" {
  description = "Default timezone for snapshot policies."
  type        = string
  default     = "UTC"
}

variable "snapshot_policies" {
  description = "Snapshot policies keyed by policy name. Use volume_key for module-managed volumes or volume_id for external volumes."
  type = map(object({
    volume_key    = optional(string)
    volume_id     = optional(string)
    schedule      = string
    interval_type = string
    max_snaps     = number
    timezone      = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for policy in var.snapshot_policies :
      (try(policy.volume_key, null) != null) != (try(policy.volume_id, null) != null)
    ])
    error_message = "Each snapshot policy must set exactly one of volume_key or volume_id."
  }

  validation {
    condition = alltrue([
      for policy in var.snapshot_policies :
      contains(["HOURLY", "DAILY", "WEEKLY", "MONTHLY"], upper(policy.interval_type))
    ])
    error_message = "Snapshot policy interval_type must be one of HOURLY, DAILY, WEEKLY, or MONTHLY."
  }

  validation {
    condition     = alltrue([for k, p in var.snapshot_policies : p.max_snaps >= 1])
    error_message = "Snapshot policy max_snaps must be at least 1."
  }
}

variable "tags" {
  description = "Not consumed by this module — cloudstack_disk does not accept tags in provider v0.6. Accepted for root module consistency but silently dropped."
  type        = map(string)
  default     = {}
}
