# CloudStack Accounts & Projects Module

Creates CloudStack domain hierarchy, accounts, users, roles, projects, and resource quotas using the Apache CloudStack Terraform provider.

One module call manages all resources for a given environment.

## Resources

| Resource              | Purpose                                                        |
| --------------------- | -------------------------------------------------------------- |
| `cloudstack_domain`   | Creates domains for account and workload isolation             |
| `cloudstack_role`     | Creates custom roles                                           |
| `cloudstack_account`  | Creates accounts with domain placement and role assignment     |
| `cloudstack_user`     | Creates additional users inside accounts                       |
| `cloudstack_project`  | Creates projects with an optional admin account                |
| `cloudstack_limits`   | Sets per-account resource quotas (CPU, RAM, storage, etc.)     |

## Domain Isolation

In CloudStack, domains are the primary isolation boundary. Accounts and their workloads are scoped to the domain they live in. This module creates domains and places accounts into them via `domain_key` (a created domain) or `domain_id` (a pre-existing domain ID).

The ZCP domain hierarchy follows this structure:

```
ROOT
└── <site>                  (parent domain)
    ├── <org>               (internal org domain)
    │   ├── infra
    │   ├── dev
    │   └── prd
    └── tenants             (external customer branch)
```

Projects provide a secondary isolation layer within an account. Adding accounts or users as project members is not supported in provider v0.6.0 — project membership must be managed via the CloudStack UI or API.

## Account Types

| `account_type` | CloudStack role |
| -------------- | --------------- |
| `0`            | User (default)  |
| `1`            | Admin           |
| `2`            | Domain Admin    |

## Role Assignment

Every account must specify exactly one of:

- `role_key` — key into `var.roles` to assign a role created by this module
- `role_id` — direct CloudStack role ID for a pre-existing built-in or custom role

## Resource Quota Types

| Field               | Provider type string | Unit  |
| ------------------- | -------------------- | ----- |
| `instances`         | `instance`           | count |
| `ips`               | `ip`                 | count |
| `volumes`           | `volume`             | count |
| `snapshots`         | `snapshot`           | count |
| `templates`         | `template`           | count |
| `networks`          | `network`            | count |
| `vpcs`              | `vpc`                | count |
| `cpu`               | `cpu`                | cores |
| `memory`            | `memory`             | MB    |
| `primary_storage`   | `primary_storage`    | GB    |
| `secondary_storage` | `secondary_storage`  | GB    |

Set any quota field to `-1` for unlimited. Omit a field to leave it unmanaged.

## Provider Limitations (v0.6.0)

- **Role permissions** — `cloudstack_role_permission` does not exist. Custom roles can be created, but API rule permissions must be assigned in the CloudStack UI after the role is created.
- **Project membership** — No resource exists for adding accounts or users as project members. Project membership must be managed via the CloudStack UI or `addAccountToProject` API.
- **Per-user role assignment** — `cloudstack_user` has no `role_id` argument. Users inherit the account-level role.

## Usage

```hcl
module "accounts_projects" {
  source = "../../modules/accounts-projects"

  domains = {
    tenants = {
      name = "tenants"
    }
    acme = {
      name             = "acme"
      parent_domain_id = var.tenant_domain_id  # must come from a prior apply or a separate module call
    }
  }

  roles = {
    tenant_user = {
      name      = "tenant-user-role"
      role_type = "User"
    }
  }

  accounts = {
    acme = {
      account    = "acme"
      email      = "admin@acme.example"
      first_name = "Acme"
      last_name  = "Admin"
      username   = "acme-admin"
      password   = var.acme_password
      domain_key = "acme"
      role_key   = "tenant_user"
    }
  }

  projects = {
    acme_web = {
      name         = "acme-web"
      display_text = "Acme Web Project"
      account_key  = "acme"
    }
  }

  quotas = {
    acme = {
      cpu             = 20
      memory          = 40960
      primary_storage = 500
      instances       = 10
    }
  }
}
```

See `examples/demo-stack` for the combined demo stack example.

## Security Note

Account and user passwords should be provided via a sensitive `.tfvars` file or environment variables. Never commit passwords to source control.
