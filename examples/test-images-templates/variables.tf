variable "cloudstack_api_url" {
  description = "CloudStack API endpoint URL."
  type        = string
}

variable "cloudstack_api_key" {
  description = "CloudStack API key for authentication."
  type        = string
  sensitive   = true
}

variable "cloudstack_secret_key" {
  description = "CloudStack secret key for authentication."
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string

  validation {
    condition     = length(trimspace(var.zone)) > 0
    error_message = "zone must not be empty."
  }
}

variable "vpc_offering" {
  description = "CloudStack VPC offering name."
  type        = string
  default     = "Default VPC offering"
}

variable "network_offering" {
  description = "CloudStack network offering name for the VPC tier."
  type        = string
  default     = "DefaultIsolatedNetworkOfferingForVpcNetworks"
}

variable "stack" {
  type    = string
  default = "docker"

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
  type    = string
  default = "test-vm.example.com"
}

variable "service_offering" {
  description = "CloudStack service offering name for the test VM."
  type        = string

  validation {
    condition     = length(trimspace(var.service_offering)) > 0
    error_message = "service_offering must not be empty."
  }
}

variable "keypair" {
  description = "SSH keypair name registered in CloudStack for VM access."
  type        = string
  default     = null
}

variable "stack_vars" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "template_name_overrides" {
  type    = map(string)
  default = {}
}
