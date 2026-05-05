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

variable "accounts_projects" {
  description = "Domains, accounts, users, roles, projects, and quotas for the demo stack."
  sensitive   = true
  type = object({
    domains = optional(map(object({
      name             = string
      parent_domain_id = optional(string)
      network_domain   = optional(string)
    })), {})
    roles = optional(map(object({
      name        = string
      description = optional(string)
      role_type   = optional(string, "User")
    })), {})
    accounts = optional(map(object({
      account      = optional(string)
      account_type = optional(number, 0)
      email        = string
      first_name   = string
      last_name    = string
      username     = string
      password     = string
      domain_id    = optional(string)
      domain_key   = optional(string)
      role_key     = optional(string)
      role_id      = optional(string)
    })), {})
    users = optional(map(object({
      username    = string
      email       = string
      first_name  = string
      last_name   = string
      password    = string
      account_key = string
    })), {})
    projects = optional(map(object({
      name         = string
      display_text = optional(string)
      account_key  = optional(string)
    })), {})
    quotas = optional(map(object({
      account_key       = string
      instances         = optional(number)
      ips               = optional(number)
      volumes           = optional(number)
      snapshots         = optional(number)
      templates         = optional(number)
      networks          = optional(number)
      vpcs              = optional(number)
      cpu               = optional(number)
      memory            = optional(number)
      primary_storage   = optional(number)
      secondary_storage = optional(number)
    })), {})
  })
  default = {
    domains = {
      demo = {
        name = "demo-domain"
      }
    }
    roles = {
      demo = {
        name      = "demo-role"
        role_type = "User"
      }
    }
    accounts = {}
    users    = {}
    projects = {
      demo = {
        name         = "demo-project"
        display_text = "ZCP Demo Project"
        account_key  = null
      }
    }
    quotas = {}
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

variable "kubernetes_clusters" {
  description = "Map of CKS clusters to create. Defaults to empty so the networking dry run remains lightweight."
  type = map(object({
    name                = string
    description         = optional(string)
    kubernetes_version  = optional(string, "1.34.3")
    service_offering    = string
    worker_count        = optional(number, 1)
    control_plane_count = optional(number, 1)
    etcd_count          = optional(number, 0)
    node_root_disk_size = optional(number, 25)
    node_offerings = optional(object({
      control = optional(string)
      worker  = optional(string)
      etcd    = optional(string)
    }), {})
    node_templates = optional(object({
      control = optional(string)
      worker  = optional(string)
      etcd    = optional(string)
    }), {})
    autoscaling_enabled      = optional(bool, false)
    autoscaling_min_size     = optional(number)
    autoscaling_max_size     = optional(number)
    network_id               = optional(string)
    keypair                  = optional(string)
    hypervisor               = optional(string, "KVM")
    cni_configuration_id     = optional(string)
    cni_config_details       = optional(map(string))
    domain_id                = optional(string)
    account                  = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
  }))
  default = {}
}

variable "kubernetes_docker_registry_passwords" {
  description = "Optional private Docker registry passwords keyed by kubernetes_clusters key."
  type        = map(string)
  default     = {}
  sensitive   = true
}

check "kubernetes_registry_password_keys_exist" {
  assert {
    condition = alltrue([
      for key, _ in nonsensitive(var.kubernetes_docker_registry_passwords) :
      contains(keys(var.kubernetes_clusters), key)
    ])
    error_message = "Each kubernetes_docker_registry_passwords key must match a key in kubernetes_clusters."
  }
}

check "kubernetes_registry_credentials_complete" {
  assert {
    condition = alltrue(concat(
      [
        for key, cluster in var.kubernetes_clusters :
        (
          cluster.docker_registry_url == null &&
          cluster.docker_registry_username == null &&
          !contains(keys(nonsensitive(var.kubernetes_docker_registry_passwords)), key)
        ) ||
        (
          cluster.docker_registry_url != null &&
          cluster.docker_registry_username != null &&
          contains(keys(nonsensitive(var.kubernetes_docker_registry_passwords)), key)
        )
      ],
      [
        for key, _ in nonsensitive(var.kubernetes_docker_registry_passwords) :
        contains(keys(var.kubernetes_clusters), key) &&
        var.kubernetes_clusters[key].docker_registry_url != null &&
        var.kubernetes_clusters[key].docker_registry_username != null
      ]
    ))
    error_message = "Kubernetes Docker registry credentials must be complete and keyed by the matching kubernetes_clusters entry."
  }
}
