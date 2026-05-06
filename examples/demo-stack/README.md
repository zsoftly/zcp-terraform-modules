# CloudStack Demo Stack

Combined Terraform example for ZCP customer/demo environments.

This stack starts with the networking and compute modules. Add storage, load
balancing, Kubernetes, VPN, and image/template modules here as they are built.

## Networking

The demo stack creates one or more VPCs from the `networking_vpcs` map. Each map
entry calls the reusable networking module once, keeping the child module scoped
to one VPC while the root stack composes multiple VPCs when needed.

The default `networking_vpcs` value creates one non-prod demo VPC using the
repo-backed ZCP offerings:

| Input            | Default                          |
| ---------------- | -------------------------------- |
| VPC offering     | `Standard VPC offering - nonprd` |
| Network offering | `VPC Tier`                       |

## Accounts & Projects

Creates domains, accounts, users, roles, projects, and resource quotas from the
`accounts_projects` object.

The default creates one domain, one role, and one project. Accounts and users
default to empty to avoid placeholder passwords reaching state. To provision
accounts and users, supply them via a separate sensitive `.tfvars` file that
is never committed:

```hcl
accounts_projects = {
  accounts = {
    dev = {
      account    = "dev-account"
      email      = "dev@example.com"
      first_name = "Dev"
      last_name  = "Team"
      username   = "devadmin"
      password   = "supplied-at-runtime"
      role_key   = "demo"
    }
  }
}
```

See `terraform.tfvars.example` for the full variable structure.

## Dry Run

```bash
cd examples/demo-stack
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

For a real ZCP dry run, copy `terraform.tfvars.example` to `terraform.tfvars`
and replace the CloudStack API values.

```bash
terraform plan
```

Do not run `terraform apply` unless the plan has been reviewed.

## Compute

The demo stack also accepts a `compute_groups` map. Each entry calls the
reusable compute module once and references a network created by the
networking module via `vpc_key` and `network_key`.

`compute_groups` defaults to an empty map so the base demo plan stays
networking-only. Populate it (or override in `terraform.tfvars`) to plan
instances. See `terraform.tfvars.example` for a sample group.

## Dry Run

```bash
cd examples/demo-stack
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

For a real ZCP dry run, copy `terraform.tfvars.example` to `terraform.tfvars`
and replace the CloudStack API values.

```bash
terraform plan
```

Do not run `terraform apply` unless the plan has been reviewed.
