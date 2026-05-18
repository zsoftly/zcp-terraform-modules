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
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
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
