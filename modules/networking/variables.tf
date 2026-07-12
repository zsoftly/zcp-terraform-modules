variable "name" {
  description = "Name of the CloudStack VPC to create."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "display_text" {
  description = "Display text for the CloudStack VPC."
  type        = string
  default     = null
}

variable "cidr" {
  description = "CIDR block for the CloudStack VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr, 0))
    error_message = "cidr must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
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

  validation {
    condition = alltrue(flatten([
      for k, acl in var.network_acls : [
        for rule in acl.rules :
        contains(["allow", "deny"], lower(rule.action))
      ]
    ]))
    error_message = "ACL rule action must be 'allow' or 'deny'."
  }

  validation {
    condition = alltrue(flatten([
      for k, acl in var.network_acls : [
        for rule in acl.rules :
        contains(["tcp", "udp", "icmp", "all"], lower(rule.protocol))
      ]
    ]))
    error_message = "ACL rule protocol must be one of: tcp, udp, icmp, all."
  }

  validation {
    condition = alltrue(flatten([
      for k, acl in var.network_acls : [
        for rule in acl.rules :
        contains(["ingress", "egress"], lower(rule.traffic_type))
      ]
    ]))
    error_message = "ACL rule traffic_type must be 'ingress' or 'egress'."
  }
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

  validation {
    condition     = alltrue([for k, n in var.networks : can(cidrhost(n.cidr, 0))])
    error_message = "Each network cidr must be a valid CIDR block (e.g. 10.0.1.0/24)."
  }

  validation {
    condition     = alltrue([for k, n in var.networks : n.vlan == null || (n.vlan >= 1 && n.vlan <= 4094)])
    error_message = "Each network vlan must be between 1 and 4094."
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
