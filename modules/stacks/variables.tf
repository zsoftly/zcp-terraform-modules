variable "stack" {
  description = "Application stack slug. Must be one of the supported stack identifiers."
  type        = string

  validation {
    condition = contains([
      "cpanel", "docker", "lamp", "drupal", "joomla",
      "wordpress", "wp-squared", "gitlab", "jitsi",
      "magento", "minecraft", "pritunl"
    ], var.stack)
    error_message = "stack must be one of: cpanel, docker, lamp, drupal, joomla, wordpress, wp-squared, gitlab, jitsi, magento, minecraft, pritunl."
  }
}

variable "hostname" {
  description = "Fully qualified hostname for the VM. Used by cloud-init to set the system hostname."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?)*$", var.hostname))
    error_message = "hostname must be a valid hostname or FQDN (e.g. myvm.example.com). Labels must start and end with alphanumeric characters."
  }
}

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

variable "stack_vars" {
  description = "Stack-specific runtime variables and secrets (passwords, keys, config values). All values are treated as sensitive."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "template_name_overrides" {
  description = "Override the default OS template name for one or more stack slugs. Keys are stack slugs, values are the exact template names as registered in your CloudStack zone. Only the stacks you specify are overridden; others use the built-in defaults."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for k, v in var.template_name_overrides :
      contains(["cpanel", "docker", "lamp", "drupal", "joomla", "wordpress", "wp-squared", "gitlab", "jitsi", "magento", "minecraft", "pritunl"], k)
    ])
    error_message = "template_name_overrides keys must be valid stack slugs: cpanel, docker, lamp, drupal, joomla, wordpress, wp-squared, gitlab, jitsi, magento, minecraft, pritunl."
  }
}

variable "cloud_init_templates_dir" {
  description = "Directory containing cloud-init .tftpl template files. Defaults to the bundled templates shipped with this module. Override to use your own templates."
  type        = string
  default     = null
}
