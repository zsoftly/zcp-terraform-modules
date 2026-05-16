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
├── networking/                 # VPCs, networks, IP ranges, ACLs
├── load-balancing-security/    # public IPs, firewall, NAT, load balancing
├── kubernetes/                 # CKS clusters and node sizing
├── vpn-connectivity/           # Site-to-site VPN gateway and connections
└── images-templates/           # Template registration, versioning, and sharing

examples/
└── demo-stack/   # combined demo stack using the modules
```

## Module Roadmap

| Module                      | Status  | Purpose                                      |
| --------------------------- | ------- | -------------------------------------------- |
| `networking`                | Ready   | VPCs, VPC tiers/networks, IP ranges, ACLs    |
| `compute`                   | Planned | Instances, templates, service offerings      |
| `storage`                   | Planned | Volumes and snapshots                        |
| `accounts-projects`         | Ready   | Domains, accounts, users, roles, projects, quotas |
| `load-balancing-security`   | Ready   | Load balancing, firewall, NAT                |
| `kubernetes`                | Ready   | Managed clusters and node pools              |
| `vpn-connectivity`          | Ready   | Site-to-site VPN gateway and connections     |
| `images-templates`          | Ready   | Image/template upload, versioning, sharing   |

Only modules with a directory under `modules/` are currently implemented.

## Dry Run

Run validation from the example root:

```bash
cd examples/demo-stack
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars.example
```

The demo stack composes the implemented modules. With the provided example
values, the plan includes networking, load balancing/security, a CKS cluster
request, accounts/projects provisioning, and a VPN gateway.

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
