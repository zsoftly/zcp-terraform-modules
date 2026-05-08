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
  default     = "yow-1"
}

variable "project" {
  description = "Optional CloudStack project name or ID."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to demo stack resources."
  type        = map(string)
  default = {
    service = "zcp"
    stack   = "demo"
  }
}

variable "networking_vpcs" {
  description = "Map of VPCs to create with their ACLs and networks."
  type = map(object({
    name           = string
    display_text   = optional(string)
    cidr           = string
    vpc_offering   = string
    network_domain = optional(string)
    tags           = optional(map(string), {})
    network_acls = optional(map(object({
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
    })), {})
    networks = map(object({
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
  }))
  default = {
    demo = {
      name         = "demo-vpc-01"
      display_text = "ZCP Demo VPC"
      cidr         = "10.20.0.0/16"
      vpc_offering = "Standard VPC offering - nonprd"
      network_acls = {
        web = {
          name        = "demo-web-tier-acl"
          description = "Demo web tier ACL"
          rules = [
            {
              rule_number  = 100
              protocol     = "tcp"
              port         = "22"
              cidr_list    = ["0.0.0.0/0"]
              traffic_type = "ingress"
              description  = "SSH access"
            },
            {
              rule_number  = 110
              protocol     = "tcp"
              port         = "80"
              cidr_list    = ["0.0.0.0/0"]
              traffic_type = "ingress"
              description  = "HTTP access"
            },
            {
              rule_number  = 120
              protocol     = "tcp"
              port         = "443"
              cidr_list    = ["0.0.0.0/0"]
              traffic_type = "ingress"
              description  = "HTTPS access"
            },
            {
              rule_number  = 130
              protocol     = "icmp"
              icmp_type    = -1
              icmp_code    = -1
              cidr_list    = ["10.20.0.0/16"]
              traffic_type = "ingress"
              description  = "Intra-VPC ICMP"
            }
          ]
        }
      }
      networks = {
        web = {
          name             = "web-tier"
          display_text     = "Web tier"
          cidr             = "10.20.1.0/24"
          gateway          = "10.20.1.1"
          startip          = "10.20.1.10"
          endip            = "10.20.1.200"
          network_offering = "VPC Tier"
          acl_key          = "web"
        }
      }
    }
  }
}

variable "load_balancing_security" {
  description = "Map of load balancing and security stacks to create."
  type = map(object({
    name                   = string
    networking_vpc_key     = optional(string)
    network_key            = optional(string)
    network_id             = optional(string)
    vpc_id                 = optional(string)
    existing_public_ip_ids = optional(map(string), {})
    public_ips = optional(map(object({
      is_portable = optional(bool, false)
      network_id  = optional(string)
      vpc_id      = optional(string)
      zone        = optional(string)
    })), {})
    firewalls = optional(map(object({
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
    })), {})
    egress_firewalls = optional(map(object({
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
    })), {})
    static_nats = optional(map(object({
      public_ip_key      = optional(string)
      ip_address_id      = optional(string)
      virtual_machine_id = string
      vm_guest_ip        = optional(string)
    })), {})
    port_forwards = optional(map(object({
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
    })), {})
    load_balancer_rules = optional(map(object({
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
    })), {})
  }))
  default = {
    demo = {
      name               = "demo-edge"
      networking_vpc_key = "demo"
      network_key        = "web"
      public_ips = {
        web = {}
      }
      firewalls = {
        web = {
          public_ip_key = "web"
          rules = [
            {
              cidr_list = ["0.0.0.0/0"]
              protocol  = "tcp"
              ports     = ["80", "443"]
            }
          ]
        }
      }
      egress_firewalls = {
        web = {
          rules = [
            {
              cidr_list = ["0.0.0.0/0"]
              protocol  = "tcp"
              ports     = ["80", "443"]
            }
          ]
        }
      }
    }
  }
}

check "load_balancing_security_network_reference_required" {
  assert {
    condition = alltrue([
      for _, stack in var.load_balancing_security :
      try(stack.network_id, null) != null ||
      (try(stack.networking_vpc_key, null) != null && try(stack.network_key, null) != null)
    ])
    error_message = "Each load_balancing_security stack must set network_id or both networking_vpc_key and network_key."
  }
}

check "load_balancing_security_vpc_key_exists" {
  assert {
    condition = alltrue([
      for _, stack in var.load_balancing_security :
      try(stack.network_id, null) != null ||
      contains(keys(var.networking_vpcs), try(stack.networking_vpc_key, ""))
    ])
    error_message = "Each load_balancing_security networking_vpc_key must reference an existing key in networking_vpcs."
  }
}

check "load_balancing_security_network_key_exists" {
  assert {
    condition = alltrue([
      for _, stack in var.load_balancing_security :
      try(stack.network_id, null) != null ||
      contains(keys(try(var.networking_vpcs[stack.networking_vpc_key].networks, {})), try(stack.network_key, ""))
    ])
    error_message = "Each load_balancing_security network_key must reference an existing network key inside its networking_vpc_key."
  }
}
