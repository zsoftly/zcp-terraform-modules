variable "zone" {
  description = "CloudStack zone name or ID where templates will be registered."
  type        = string

  validation {
    condition     = var.zone != null && length(trimspace(var.zone)) > 0
    error_message = "zone must not be empty."
  }
}

variable "tags" {
  description = "Tags applied to all templates managed by this module. Per-template tags are merged on top."
  type        = map(string)
  default     = {}
}

variable "project" {
  description = "Default CloudStack project to scope all templates. A per-template project value overrides this."
  type        = string
  default     = null
}

variable "templates" {
  description = "Templates to register. Each entry maps a logical key to a CloudStack template definition."
  type = map(object({
    name             = string
    url              = string
    os_type          = string
    version          = optional(string)
    display_text     = optional(string)
    format           = optional(string, "QCOW2")
    hypervisor       = optional(string, "KVM")
    is_public        = optional(bool, false)
    is_featured      = optional(bool, false)
    is_extractable   = optional(bool, false)
    password_enabled = optional(bool, false)
    for_cks          = optional(bool, false)
    is_ready_timeout = optional(string, "30m")
    project          = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([for k, t in var.templates : contains(["QCOW2", "RAW", "VHD", "OVA", "ISO", "VHDX",
    "BAREMETAL"], t.format) && length(t.name) > 0 && length(t.os_type) > 0])
    error_message = "template format must be one of: QCOW2, RAW, VHD, OVA, ISO, VHDX, BAREMETAL; name and os_type must not be empty."
  }

  validation {
    condition = alltrue([for k, t in var.templates : contains(["KVM", "VMware", "XenServer", "BareMetal",
    "Simulator", "Hyperv", "LXC"], t.hypervisor)])
    error_message = "template hypervisor must be one of: KVM, VMware, XenServer, BareMetal, Simulator, Hyperv, LXC."
  }

  validation {
    condition     = alltrue([for k, t in var.templates : t.version == null || can(regex("^[0-9]", t.version))])
    error_message = "template version must start with a digit (e.g. \"1.0.0\") — do not include a leading \"v\"."
  }

  validation {
    condition     = alltrue([for k, t in var.templates : can(regex("^https://", t.url))])
    error_message = "Each template url must start with https://."
  }

  validation {
    condition     = alltrue([for k, t in var.templates : can(regex("^[1-9][0-9]*[smh]$", t.is_ready_timeout))])
    error_message = "Each template is_ready_timeout must be a duration string ending in s, m, or h (e.g. 30m, 1h, 3600s)."
  }
}
