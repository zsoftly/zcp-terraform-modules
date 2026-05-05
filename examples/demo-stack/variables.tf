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

variable "compute_groups" {
  description = "Map of compute groups. Each group calls the compute module once and references a network created by the networking module via vpc_key + network_key."
  type = map(object({
    vpc_key                  = string
    network_key              = string
    default_service_offering = string
    default_template         = string
    create_ssh_keypair       = optional(bool, false)
    ssh_keypair_name         = optional(string)
    ssh_public_key           = optional(string)
    tags                     = optional(map(string), {})
    affinity_groups = optional(map(object({
      name        = string
      type        = string
      description = optional(string)
    })), {})
    instances = map(object({
      name                = string
      display_name        = optional(string)
      service_offering    = optional(string)
      template            = optional(string)
      network_id          = optional(string)
      ip_address          = optional(string)
      keypair             = optional(string)
      user_data           = optional(string)
      root_disk_size      = optional(number)
      group               = optional(string)
      start_vm            = optional(bool, true)
      affinity_group_keys = optional(list(string), [])
      tags                = optional(map(string), {})
      data_disks = optional(map(object({
        disk_offering = string
        size          = optional(number)
        shrink_ok     = optional(bool, false)
        device_id     = optional(number)
      })), {})
    }))
  }))
  default = {}
}
