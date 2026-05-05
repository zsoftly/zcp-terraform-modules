# CloudStack Accounts & Projects Module

Creates reusable CloudStack account, user, role, and project resources using the Apache CloudStack Terraform provider.

One module call manages all accounts and projects for a given domain or environment.

## Resources

| Resource            | Purpose                                        |
| ------------------- | ---------------------------------------------- |
| `cloudstack_role`   | Creates custom roles                           |
| `cloudstack_account`| Creates accounts with role assignment          |
| `cloudstack_user`   | Creates additional users inside accounts       |
| `cloudstack_project`| Creates projects with an optional admin account|

## Provider Limitations (v0.6.0)

Two features from the acceptance criteria are not available as native Terraform resources in cloudstack/cloudstack v0.6.0:

- **Role permissions** — `cloudstack_role_permission` does not exist. Custom roles can be created (name and type), but permission rules must be assigned in the CloudStack UI or via the CloudStack API after the role is created.
- **Resource quotas** — `cloudstack_resource_limit` does not exist. CPU, RAM, and storage limits must be set in the CloudStack UI or via the `updateResourceLimit` API after accounts are created.

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

## Usage

```hcl
module "accounts_projects" {
  source = "../../modules/accounts-projects"

  roles = {
    dev = {
      name      = "dev-role"
      role_type = "User"
    }
  }

  accounts = {
    dev = {
      account    = "dev-account"
      email      = "dev@example.com"
      first_name = "Dev"
      last_name  = "Team"
      username   = "devadmin"
      password   = var.dev_account_password
      role_key   = "dev"
    }
  }

  projects = {
    dev = {
      name         = "dev-project"
      display_text = "Development Project"
      account_key  = "dev"
    }
  }
}
```

See `examples/demo-stack` for the combined demo stack example.

## Security Note

Account and user passwords should be provided via a sensitive `.tfvars` file or environment variables. Never commit passwords to source control.
