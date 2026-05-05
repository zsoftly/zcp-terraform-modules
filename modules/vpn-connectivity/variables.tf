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
}
