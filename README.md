# ZPCP: Terraform Modules for Apache CloudStack

Terraform modules and examples for provisioning infrastructure on
[Apache CloudStack](https://cloudstack.apache.org) (ACS) by ZSoftly.

## Purpose

This repo provides reusable, composable Terraform modules for Apache CloudStack
infrastructure automation:

- spin up demo environments quickly
- standardize customer onboarding infrastructure
- keep Terraform usage aligned with ZSoftly ACS service offerings
- provide a growing end-to-end demo stack as modules are added

## Structure

```text
modules/
├── networking/                 # VPCs, networks, IP ranges, ACLs
├── compute/                    # Instances, SSH keypairs, affinity groups, data disks
├── load-balancing-security/    # public IPs, firewall, NAT, load balancing
├── storage/                    # volumes, attachments, snapshot policies
├── kubernetes/                 # CKS clusters and node sizing
├── accounts-projects/          # Domains, accounts, users, roles, projects, quotas
├── vpn-connectivity/           # Site-to-site VPN gateway and connections
├── images-templates/           # Template registration, versioning, and sharing
└── stacks/                     # Pre-configured app stack selection and cloud-init rendering

examples/
└── demo-stack/   # combined demo stack using the modules
```

## Module Roadmap

| Module                    | Status      | Purpose                                                              |
| ------------------------- | ----------- | -------------------------------------------------------------------- |
| `networking`              | Ready       | VPCs, VPC tiers/networks, IP ranges, ACLs                            |
| `compute`                 | Ready       | Instances, templates, service offerings                              |
| `storage`                 | Ready       | Volumes and snapshots                                                |
| `accounts-projects`       | Ready       | Domains, accounts, users, roles, projects, quotas                    |
| `load-balancing-security` | Ready       | Load balancing, firewall, NAT                                        |
| `kubernetes`              | Ready       | Managed clusters and node pools                                      |
| `vpn-connectivity`        | Ready       | Site-to-site VPN gateway and connections                             |
| `images-templates`        | Ready       | Image/template upload, versioning, sharing                           |
| `stacks`                  | In Progress | Pre-configured app stack selection and cloud-init userdata rendering |

Only modules with a directory under `modules/` are currently implemented.

## Validation

Run schema validation without credentials:

```bash
make validate
```

This runs `terraform init -backend=false` and `terraform validate` against every
example. No CloudStack credentials required.

## Plan Against a Live Zone

`terraform plan` requires a live CloudStack API. The provider resolves offering
names, zone IDs, and other attributes at plan time. Copy the example vars file,
fill in real credentials, and run:

```bash
cd examples/demo-stack
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with real api_url, api_key, secret_key
terraform init
terraform plan
```

Do not run `terraform apply` unless the plan has been reviewed.

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
