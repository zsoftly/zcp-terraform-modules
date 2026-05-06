variable "vpc_id" {
  description = "ID of the CloudStack VPC to attach the VPN gateway to."
  type        = string
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "customer_gateways" {
  description = "Remote peers for site-to-site VPN. Map is marked sensitive because entries contain pre-shared keys."
  type = map(object({
    name         = string
    gateway      = string
    cidr         = string
    ipsec_psk    = string
    esp_policy   = string
    ike_policy   = string
    dpd          = optional(bool, false)
    esp_lifetime = optional(number, 3600)
    ike_lifetime = optional(number, 86400)
  }))
  sensitive = true
  default   = {}

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      can(cidrhost(v.cidr, 0))
    ])
    error_message = "Each customer_gateways[*].cidr must be a valid CIDR block (e.g. 192.168.1.0/24)."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", v.gateway))
    ])
    error_message = "Each customer_gateways[*].gateway must be a valid IPv4 address."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      length(v.ipsec_psk) >= 16
    ])
    error_message = "Each customer_gateways[*].ipsec_psk must be at least 16 characters."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      can(regex("^[a-z0-9]+-[a-z0-9]+;[a-z0-9]+$", v.esp_policy))
    ])
    error_message = "Each customer_gateways[*].esp_policy must use the format algo-hash;dh-group (e.g. aes256-sha256;modp2048)."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      can(regex("^[a-z0-9]+-[a-z0-9]+;[a-z0-9]+$", v.ike_policy))
    ])
    error_message = "Each customer_gateways[*].ike_policy must use the format algo-hash;dh-group (e.g. aes256-sha256;modp2048)."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      v.esp_lifetime >= 60
    ])
    error_message = "Each customer_gateways[*].esp_lifetime must be at least 60 seconds."
  }

  validation {
    condition = alltrue([
      for k, v in var.customer_gateways :
      v.ike_lifetime >= 60
    ])
    error_message = "Each customer_gateways[*].ike_lifetime must be at least 60 seconds."
  }
}
