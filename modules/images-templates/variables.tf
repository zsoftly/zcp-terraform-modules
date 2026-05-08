variable "zone" {
  description = "CloudStack zone name or ID where templates will be registered."
  type        = string
}

variable "tags" {
  description = "Tags applied to all templates managed by this module. Per-template tags are merged on top."
  type        = map(string)
  default     = {}
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
    project          = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}

  validation {
    condition = alltrue([for k, t in var.templates : contains(["QCOW2", "RAW", "VHD", "OVA", "ISO", "VHDX",
    "BAREMETAL"], t.format)])
    error_message = "template format must be one of: QCOW2, RAW, VHD, OVA, ISO, VHDX, BAREMETAL."
  }

  validation {
    condition = alltrue([for k, t in var.templates : contains(["KVM", "VMware", "XenServer", "BareMetal",
    "Simulator"], t.hypervisor)])
    error_message = "template hypervisor must be one of: KVM, VMware, XenServer, BareMetal, Simulator."
  }
}
