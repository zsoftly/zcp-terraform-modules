variable "roles" {
  description = "Custom CloudStack roles to create. Permissions must be assigned in the CloudStack UI — the v0.6.0 provider does not support cloudstack_role_permission."
  type = map(object({
    name        = string
    description = optional(string)
    role_type   = optional(string, "User")
  }))
  default = {}
}

variable "accounts" {
  description = "CloudStack accounts to create. Each account must specify either role_key or role_id. Passwords must be supplied via a sensitive var file or environment variable — do not commit values."
  type = map(object({
    account      = optional(string)
    account_type = optional(number, 0)
    email        = string
    first_name   = string
    last_name    = string
    username     = string
    password     = string
    domain_id    = optional(string)
    role_key     = optional(string)
    role_id      = optional(string)
  }))
  default = {}
}

variable "users" {
  description = "Additional users to create inside existing accounts. Passwords must be supplied via a sensitive var file or environment variable."
  type = map(object({
    username    = string
    email       = string
    first_name  = string
    last_name   = string
    password    = string
    account_key = string
  }))
  default = {}
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

check "account_role_required" {
  assert {
    condition     = alltrue([for k, a in var.accounts : a.role_key != null || a.role_id != null])
    error_message = "Each account must specify either role_key (a key into var.roles) or role_id (an existing CloudStack role ID)."
  }
}
