# ZPCP Terraform Modules

Terraform modules and examples for provisioning customer and demo environments
on ZSoftly Private Cloud Platform using Apache CloudStack.

## Purpose

This repo provides reusable, composable Terraform modules for ZCP enablement:

- spin up demo environments quickly
- standardize customer onboarding infrastructure
- keep Terraform usage aligned with ZCP service offerings
- provide a growing end-to-end demo stack as modules are added

## Structure

```text
modules/
└── networking/   # VPCs, networks, IP ranges, ACLs

examples/
└── demo-stack/   # combined demo stack using the modules
```

## Module Roadmap

| Module                      | Status  | Purpose                                      |
| --------------------------- | ------- | -------------------------------------------- |
| `networking`                | Ready   | VPCs, VPC tiers/networks, IP ranges, ACLs    |
| `compute`                   | Planned | Instances, templates, service offerings      |
| `storage`                   | Planned | Volumes and snapshots                        |
| `accounts-projects`         | Planned | Accounts, projects, users, roles, quotas     |
| `load-balancing-security`   | Planned | Load balancing, firewall, NAT                |
| `kubernetes`                | Planned | Managed clusters and node pools              |
| `vpn-connectivity`          | Planned | Site-to-site VPN and remote access           |
| `images-templates`          | Planned | Image/template upload, versioning, sharing   |

Only modules with a directory under `modules/` are currently implemented.

## Dry Run

Run validation from the example root:

```bash
cd examples/demo-stack
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

The default demo stack currently plans:

- 1 VPC
- 1 VPC tier/network
- 1 network ACL
- 4 ACL rules

## Provider Lock File

`examples/demo-stack/.terraform.lock.hcl` is committed because
`examples/demo-stack` is a Terraform root module. It pins the CloudStack
provider version and checksums selected by `terraform init`, keeping local and
CI dry runs reproducible.

Do not commit:

- `.terraform/`
- `terraform.tfvars`
- Terraform state files
- Terraform plan files

## Contribution Workflow

Create changes on a feature branch and open a pull request against `main`.

```bash
git switch -c feature/<module-or-change-name>
terraform fmt -recursive .
```

Run `terraform validate` and `terraform plan` from the relevant example root
before opening a PR.
