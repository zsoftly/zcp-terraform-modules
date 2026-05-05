output "domains" {
  description = "Created domain details keyed by input key."
  value = {
    for key, domain in cloudstack_domain.this : key => {
      id             = domain.id
      name           = domain.name
      network_domain = domain.network_domain
    }
  }
}

output "domain_ids" {
  description = "Created domain IDs keyed by input key."
  value = {
    for key, domain in cloudstack_domain.this : key => domain.id
  }
}

output "accounts" {
  description = "Created account details keyed by input key."
  sensitive   = true
  value = {
    for key, account in cloudstack_account.this : key => {
      id           = account.id
      name         = account.account
      account_type = account.account_type
      username     = account.username
    }
  }
}

output "account_ids" {
  description = "Created account IDs keyed by input key."
  value = {
    for key, account in cloudstack_account.this : key => account.id
  }
}

output "users" {
  description = "Created user details keyed by input key."
  sensitive   = true
  value = {
    for key, user in cloudstack_user.this : key => {
      id       = user.id
      username = user.username
      account  = user.account
    }
  }
}

output "roles" {
  description = "Created role details keyed by input key."
  value = {
    for key, role in cloudstack_role.this : key => {
      id        = role.id
      name      = role.name
      role_type = role.type
    }
  }
}

output "projects" {
  description = "Created project details keyed by input key."
  value = {
    for key, project in cloudstack_project.this : key => {
      id           = project.id
      name         = project.name
      display_text = project.displaytext
    }
  }
}

output "project_ids" {
  description = "Created project IDs keyed by input key."
  value = {
    for key, project in cloudstack_project.this : key => project.id
  }
}
