variable "cloudstack_api_url" {
  description = "CloudStack API endpoint URL."
  type        = string
}

variable "cloudstack_api_key" {
  description = "CloudStack API key."
  type        = string
  sensitive   = true
}

variable "cloudstack_secret_key" {
  description = "CloudStack secret key."
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
}

variable "project" {
  description = "Optional CloudStack project to scope all templates."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all templates in this QA workspace."
  type        = map(string)
  default     = {}
}

variable "templates" {
  description = "Templates to register. Supply via tfvars — do not commit real URLs or credentials."
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
    is_ready_timeout = optional(number, 300)
    project          = optional(string)
    tags             = optional(map(string), {})
  }))
  default = {}
}
