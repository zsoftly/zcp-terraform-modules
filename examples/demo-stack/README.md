# CloudStack Demo Stack

Combined Terraform example for ZCP customer/demo environments.

This stack starts with the networking module. Add compute, storage, load
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
