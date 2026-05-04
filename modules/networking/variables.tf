variable "name" {
  description = "Name of the CloudStack VPC to create."
  type        = string
}

variable "display_text" {
  description = "Display text for the CloudStack VPC."
  type        = string
  default     = null
}

variable "cidr" {
  description = "CIDR block for the CloudStack VPC."
  type        = string
}

variable "zone" {
  description = "CloudStack zone name or ID."
  type        = string
}

variable "vpc_offering" {
  description = "CloudStack VPC offering name or ID."
  type        = string
}

variable "network_domain" {
  description = "Optional DNS domain to assign to the VPC and networks."
  type        = string
  default     = null
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "create_vpc" {
  description = "Whether to create a new VPC. Set false to attach networks to existing_vpc_id."
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "Existing VPC ID used when create_vpc is false."
  type        = string
  default     = null
}

variable "network_acls" {
  description = "Network ACL lists and optional rules to create for VPC tier attachment."
  type = map(object({
    name        = string
    description = optional(string)
    rules = optional(list(object({
      rule_number  = optional(number)
      action       = optional(string, "allow")
      cidr_list    = list(string)
      protocol     = string
      port         = optional(string)
      icmp_type    = optional(number)
      icmp_code    = optional(number)
      traffic_type = optional(string, "ingress")
      description  = optional(string)
    })), [])
  }))
  default = {}
}

variable "networks" {
  description = "CloudStack networks or VPC tiers to create."
  type = map(object({
    name             = string
    display_text     = optional(string)
    cidr             = string
    gateway          = optional(string)
    startip          = optional(string)
    endip            = optional(string)
    network_domain   = optional(string)
    network_offering = string
    vlan             = optional(number)
    attach_to_vpc    = optional(bool, true)
    acl_key          = optional(string)
    source_nat_ip    = optional(bool, false)
    tags             = optional(map(string), {})
  }))

  validation {
    condition     = length(var.networks) > 0
    error_message = "At least one network must be defined."
  }
}

variable "tags" {
  description = "Tags applied to VPC and networks."
  type        = map(string)
  default     = {}
}

check "existing_vpc_id_required" {
  assert {
    condition     = var.create_vpc || var.existing_vpc_id != null
    error_message = "existing_vpc_id is required when create_vpc is false."
  }
}
