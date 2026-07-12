variable "domains" {
  description = "CloudStack domains to create. Used to establish the domain hierarchy for account and workload isolation."
  type = map(object({
    name             = string
    parent_domain_id = optional(string)
    network_domain   = optional(string)
  }))
  default = {}
}

variable "roles" {
  description = "Custom CloudStack roles to create. Permissions must be assigned in the CloudStack UI — the v0.6.0 provider does not support cloudstack_role_permission."
  type = map(object({
    name        = string
    description = optional(string)
    role_type   = optional(string, "User")
  }))
  default = {}

  validation {
    condition     = alltrue([for k, r in var.roles : contains(["User", "Admin", "DomainAdmin", "ResourceAdmin"], r.role_type)])
    error_message = "role_type must be one of: User, Admin, DomainAdmin, ResourceAdmin."
  }
}

variable "accounts" {
  description = "CloudStack accounts to create. Each account must specify either role_key or role_id. Passwords must be supplied via a sensitive var file or environment variable — do not commit values."
  sensitive   = true
  type = map(object({
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
  }))
  default = {}

  validation {
    condition     = alltrue([for k, a in var.accounts : contains([0, 1, 2], a.account_type)])
    error_message = "account_type must be 0 (User), 1 (Admin), or 2 (Domain Admin)."
  }

  validation {
    condition     = alltrue([for k, v in var.accounts : v.role_key != null || v.role_id != null])
    error_message = "Each account must specify either role_key (module-created role) or role_id (pre-existing role)."
  }

  validation {
    condition     = alltrue([for k, a in var.accounts : can(regex("^[^@]+@[^@]+\\.[^@]+$", a.email))])
    error_message = "Each account email must be a valid email address."
  }

  validation {
    condition     = alltrue([for k, a in var.accounts : length(trimspace(a.username)) > 0])
    error_message = "Each account username must not be empty."
  }
}

variable "users" {
  description = "Additional users to create inside existing accounts. Passwords must be supplied via a sensitive var file or environment variable."
  sensitive   = true
  type = map(object({
    username    = string
    email       = string
    first_name  = string
    last_name   = string
    password    = string
    account_key = string
  }))
  default = {}

  validation {
    condition     = alltrue([for k, u in var.users : can(regex("^[^@]+@[^@]+\\.[^@]+$", u.email))])
    error_message = "Each user email must be a valid email address."
  }

  validation {
    condition     = alltrue([for k, u in var.users : length(trimspace(u.username)) > 0])
    error_message = "Each user username must not be empty."
  }
}

variable "projects" {
  description = "CloudStack projects to create."
  type = map(object({
    name         = string
    display_text = optional(string)
    account_key  = optional(string)
  }))
  default = {}
}

variable "quotas" {
  description = "Resource limits per account. Set a field to -1 for unlimited, or omit to leave unmanaged."
  type = map(object({
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
  }))
  default = {}

  validation {
    condition = alltrue(flatten([
      for k, q in var.quotas : [
        q.instances == null || q.instances >= -1,
        q.ips == null || q.ips >= -1,
        q.volumes == null || q.volumes >= -1,
        q.snapshots == null || q.snapshots >= -1,
        q.templates == null || q.templates >= -1,
        q.networks == null || q.networks >= -1,
        q.vpcs == null || q.vpcs >= -1,
        q.cpu == null || q.cpu >= -1,
        q.memory == null || q.memory >= -1,
        q.primary_storage == null || q.primary_storage >= -1,
        q.secondary_storage == null || q.secondary_storage >= -1,
      ]
    ]))
    error_message = "Quota values must be -1 (unlimited) or a non-negative integer."
  }
}

check "user_account_key_exists" {
  assert {
    condition     = alltrue([for k, u in var.users : contains(keys(var.accounts), u.account_key)])
    error_message = "All users[*].account_key values must correspond to a key in var.accounts."
  }
}

check "project_account_key_exists" {
  assert {
    condition     = alltrue([for k, p in var.projects : p.account_key == null || contains(keys(var.accounts), p.account_key)])
    error_message = "All projects[*].account_key values must correspond to a key in var.accounts."
  }
}

check "quota_account_key_exists" {
  assert {
    condition     = alltrue([for k, q in var.quotas : contains(keys(var.accounts), k)])
    error_message = "Each quotas map key must correspond to a key in var.accounts."
  }
}

check "account_role_key_exists" {
  assert {
    condition     = alltrue([for k, a in var.accounts : a.role_key == null || contains(keys(var.roles), a.role_key)])
    error_message = "accounts[*].role_key must be a key in var.roles."
  }
}

check "account_domain_key_exists" {
  assert {
    condition     = alltrue([for k, a in var.accounts : a.domain_key == null || contains(keys(var.domains), a.domain_key)])
    error_message = "accounts[*].domain_key must be a key in var.domains."
  }
}
