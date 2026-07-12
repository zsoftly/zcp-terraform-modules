variable "name" {
  description = "Logical name for this traffic and security configuration."
  type        = string

  validation {
    condition     = var.name != null && length(trimspace(var.name)) > 0
    error_message = "name must not be empty."
  }
}

variable "zone" {
  description = "CloudStack zone name or ID used for public IP allocation."
  type        = string
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "network_id" {
  description = "Default CloudStack network ID for IP allocation, egress rules, and VPC load balancer rules."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "Optional default VPC ID for public IP allocation."
  type        = string
  default     = null
}

variable "existing_public_ip_ids" {
  description = "Existing public IP IDs that can be referenced by public_ip_key."
  type        = map(string)
  default     = {}
}

variable "public_ips" {
  description = "Public IPs to acquire and associate."
  type = map(object({
    is_portable = optional(bool, false)
    network_id  = optional(string)
    vpc_id      = optional(string)
    zone        = optional(string)
  }))
  default = {}
}

variable "firewalls" {
  description = "Ingress firewall rule sets keyed by logical name."
  type = map(object({
    public_ip_key = optional(string)
    ip_address_id = optional(string)
    managed       = optional(bool, false)
    parallelism   = optional(number, 2)
    rules = list(object({
      cidr_list = list(string)
      protocol  = string
      ports     = optional(list(string))
      icmp_type = optional(number)
      icmp_code = optional(number)
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for k, fw in var.firewalls : [
        for rule in fw.rules :
        contains(["tcp", "udp", "icmp", "all"], lower(rule.protocol))
      ]
    ]))
    error_message = "Firewall rule protocol must be one of: tcp, udp, icmp, all."
  }
}

variable "egress_firewalls" {
  description = "Egress firewall rule sets keyed by logical name."
  type = map(object({
    network_id  = optional(string)
    managed     = optional(bool, false)
    parallelism = optional(number, 2)
    rules = list(object({
      cidr_list = list(string)
      protocol  = string
      ports     = optional(list(string))
      icmp_type = optional(number)
      icmp_code = optional(number)
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for k, fw in var.egress_firewalls : [
        for rule in fw.rules :
        contains(["tcp", "udp", "icmp", "all"], lower(rule.protocol))
      ]
    ]))
    error_message = "Egress firewall rule protocol must be one of: tcp, udp, icmp, all."
  }
}

variable "static_nats" {
  description = "Static NAT mappings keyed by logical name."
  type = map(object({
    public_ip_key      = optional(string)
    ip_address_id      = optional(string)
    virtual_machine_id = string
    vm_guest_ip        = optional(string)
  }))
  default = {}
}

variable "port_forwards" {
  description = "Port forwarding rule sets keyed by logical name."
  type = map(object({
    public_ip_key = optional(string)
    ip_address_id = optional(string)
    managed       = optional(bool, false)
    forwards = list(object({
      protocol           = string
      private_port       = number
      public_port        = number
      virtual_machine_id = string
      vm_guest_ip        = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for k, pf in var.port_forwards : [
        for fwd in pf.forwards :
        contains(["tcp", "udp"], lower(fwd.protocol))
      ]
    ]))
    error_message = "Port forward protocol must be 'tcp' or 'udp'."
  }
}

variable "load_balancer_rules" {
  description = "Load balancer rules keyed by logical name."
  type = map(object({
    name          = string
    description   = optional(string)
    public_ip_key = optional(string)
    ip_address_id = optional(string)
    network_id    = optional(string)
    algorithm     = string
    private_port  = number
    public_port   = number
    protocol      = optional(string, "tcp")
    member_ids    = list(string)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, lb in var.load_balancer_rules : contains(["tcp", "udp"], lower(lb.protocol))])
    error_message = "Load balancer rule protocol must be 'tcp' or 'udp'."
  }
}

check "public_ip_reference_required" {
  assert {
    condition = alltrue(concat(
      [for _, firewall in var.firewalls : try(firewall.public_ip_key, null) != null || try(firewall.ip_address_id, null) != null],
      [for _, static_nat in var.static_nats : try(static_nat.public_ip_key, null) != null || try(static_nat.ip_address_id, null) != null],
      [for _, port_forward in var.port_forwards : try(port_forward.public_ip_key, null) != null || try(port_forward.ip_address_id, null) != null],
      [for _, load_balancer in var.load_balancer_rules : try(load_balancer.public_ip_key, null) != null || try(load_balancer.ip_address_id, null) != null]
    ))
    error_message = "Each firewall, static NAT, port forward, and load balancer rule must set either public_ip_key or ip_address_id."
  }
}

check "public_ip_keys_exist" {
  assert {
    condition = alltrue(concat(
      [for _, firewall in var.firewalls : try(firewall.public_ip_key, null) == null || contains(keys(merge(var.existing_public_ip_ids, var.public_ips)), firewall.public_ip_key)],
      [for _, static_nat in var.static_nats : try(static_nat.public_ip_key, null) == null || contains(keys(merge(var.existing_public_ip_ids, var.public_ips)), static_nat.public_ip_key)],
      [for _, port_forward in var.port_forwards : try(port_forward.public_ip_key, null) == null || contains(keys(merge(var.existing_public_ip_ids, var.public_ips)), port_forward.public_ip_key)],
      [for _, load_balancer in var.load_balancer_rules : try(load_balancer.public_ip_key, null) == null || contains(keys(merge(var.existing_public_ip_ids, var.public_ips)), load_balancer.public_ip_key)]
    ))
    error_message = "Each public_ip_key must reference a key in public_ips or existing_public_ip_ids."
  }
}

check "public_ip_allocation_scope_valid" {
  assert {
    condition = alltrue([
      for _, public_ip in var.public_ips :
      (
        (try(public_ip.network_id, null) != null ? public_ip.network_id : var.network_id) != null &&
        (try(public_ip.vpc_id, null) != null ? public_ip.vpc_id : var.vpc_id) == null
        ) || (
        (try(public_ip.network_id, null) != null ? public_ip.network_id : var.network_id) == null &&
        (try(public_ip.vpc_id, null) != null ? public_ip.vpc_id : var.vpc_id) != null
      )
    ])
    error_message = "Each public IP must resolve to exactly one allocation scope: network_id or vpc_id."
  }
}

check "egress_firewall_network_required" {
  assert {
    condition = alltrue([
      for _, firewall in var.egress_firewalls :
      (try(firewall.network_id, null) != null ? firewall.network_id : var.network_id) != null
    ])
    error_message = "Each egress firewall must set network_id or use module-level network_id."
  }
}

check "load_balancer_algorithms_supported" {
  assert {
    condition = alltrue([
      for _, load_balancer in var.load_balancer_rules :
      contains(["roundrobin", "leastconn", "source"], load_balancer.algorithm)
    ])
    error_message = "Load balancer algorithm must be one of: roundrobin, leastconn, source."
  }
}

check "port_forward_ports_valid" {
  assert {
    condition = alltrue(flatten([
      for _, port_forward in var.port_forwards : [
        for forward in port_forward.forwards :
        forward.private_port >= 1 && forward.private_port <= 65535 &&
        forward.public_port >= 1 && forward.public_port <= 65535
      ]
    ]))
    error_message = "Port forwarding private_port and public_port values must be between 1 and 65535."
  }
}

check "load_balancer_ports_valid" {
  assert {
    condition = alltrue([
      for _, load_balancer in var.load_balancer_rules :
      load_balancer.private_port >= 1 && load_balancer.private_port <= 65535 &&
      load_balancer.public_port >= 1 && load_balancer.public_port <= 65535
    ])
    error_message = "Load balancer private_port and public_port values must be between 1 and 65535."
  }
}

check "load_balancer_members_required" {
  assert {
    condition = alltrue([
      for _, load_balancer in var.load_balancer_rules :
      length(load_balancer.member_ids) > 0
    ])
    error_message = "Each load balancer rule must include at least one member ID."
  }
}
