# stacks

Selects an application stack, resolves the correct CloudStack OS template, and
renders the cloud-init userdata for the selected stack.

This module does not create VMs. It produces two outputs, `template_id` and
`rendered_userdata`, for the calling compute resource to consume.

## Supported Stacks

| Slug         | Base OS      | Min CPU | Min RAM | Min Disk | Offering |
| ------------ | ------------ | ------- | ------- | -------- | -------- |
| `cpanel`     | AlmaLinux 9  | 2       | 2 GB    | 40 GB    | CI1-4    |
| `docker`     | Ubuntu 24.04 | 1       | 1 GB    | 20 GB    | CI1-1    |
| `lamp`       | Ubuntu 24.04 | 1       | 1 GB    | 20 GB    | CI1-1    |
| `drupal`     | Ubuntu 24.04 | 2       | 2 GB    | 20 GB    | CI1-4    |
| `joomla`     | Ubuntu 24.04 | 2       | 2 GB    | 20 GB    | CI1-4    |
| `wordpress`  | Ubuntu 24.04 | 1       | 1 GB    | 20 GB    | CI1-1    |
| `wp-squared` | Ubuntu 24.04 | 2       | 2 GB    | 30 GB    | CI1-4    |
| `gitlab`     | Ubuntu 24.04 | 4       | 8 GB    | 50 GB    | CI1-16   |
| `jitsi`      | Ubuntu 24.04 | 2       | 4 GB    | 20 GB    | CI1-8    |
| `magento`    | Ubuntu 24.04 | 4       | 4 GB    | 50 GB    | CI1-8    |
| `minecraft`  | Ubuntu 24.04 | 2       | 2 GB    | 20 GB    | CI1-4    |
| `pritunl`    | Ubuntu 24.04 | 1       | 1 GB    | 20 GB    | CI1-1    |

## Usage

```hcl
module "stacks" {
  source = "../../modules/stacks"

  stack    = "docker"
  hostname = "docker01.example.com"
  zone     = var.zone
  project  = var.project

  stack_vars = {}
}

resource "cloudstack_instance" "app" {
  name             = "docker01"
  zone             = var.zone
  template         = module.stacks.template_id
  service_offering = module.stacks.min_sizing.service_offering
  user_data        = module.stacks.rendered_userdata
}
```

Pass `stack_vars` to inject stack-specific secrets and config values. Each key
maps to a Terraform template variable inside the `.tftpl` file.

## Template Name Overrides

The module maps each stack slug to a default OS template name registered in
`locals.tf`. Override any entry by passing `template_name_overrides`:

```hcl
template_name_overrides = {
  docker = "Ubuntu-24.04-LTS-custom"
}
```

Only the slugs you specify are overridden. All others use the built-in defaults.

## Sizing

`min_sizing` exposes the minimum CPU, RAM (MB), disk (GB), and recommended
service offering for the selected stack. Use this output in the calling compute
resource to enforce the minimum spec before provisioning.

## Secrets

All values in `stack_vars` are treated as sensitive. The `rendered_userdata`
output is also marked `sensitive = true` and will not appear in `terraform plan`
or `terraform apply` console output.

Never commit stack secrets to source control. Pass them via environment
variables (`TF_VAR_*`) or a secrets manager in CI.

## Sharing

| Requirement                           | How                                                                                    |
| ------------------------------------- | -------------------------------------------------------------------------------------- |
| Available to all accounts in the zone | `is_public = true` on the underlying template                                          |
| Restricted to a single project        | Pass `project` to scope the template lookup                                            |
| Per-account sharing                   | Not supported by provider v0.6. Use CloudStack UI or API (`updateTemplatePermissions`) |

## Inputs

| Name                      | Description                                                                | Type          | Default    | Required |
| ------------------------- | -------------------------------------------------------------------------- | ------------- | ---------- | -------- |
| `stack`                   | Application stack slug                                                     | `string`      | (required) | yes      |
| `hostname`                | Fully qualified hostname for the VM                                        | `string`      | (required) | yes      |
| `zone`                    | CloudStack zone name or ID                                                 | `string`      | (required) | yes      |
| `project`                 | Optional CloudStack project name or ID                                     | `string`      | `null`     | no       |
| `stack_vars`              | Stack-specific secrets and config values. All values treated as sensitive. | `map(string)` | `{}`       | no       |
| `template_name_overrides` | Override default OS template names per stack slug                          | `map(string)` | `{}`       | no       |

## Outputs

| Name                | Description                                                                             |
| ------------------- | --------------------------------------------------------------------------------------- |
| `template_id`       | CloudStack template ID resolved for the selected stack                                  |
| `template_name`     | CloudStack template name resolved for the selected stack                                |
| `stack`             | The stack slug passed in, for reference by the calling module                           |
| `rendered_userdata` | Base64-encoded cloud-init userdata. Pass to `cloudstack_instance.user_data`. Sensitive. |
| `min_sizing`        | Minimum CPU, RAM (MB), disk (GB), and service offering for the selected stack           |

## Notes

The module looks up the OS template from CloudStack at plan time using
`template_filter = "executable"`. If the template name in `locals.tf` does not
match a registered template in the target zone, `terraform plan` fails with a
clear error. This is intentional: it surfaces misconfiguration early.

On private management networks with no external exposure, HTTP mirrors for
template URLs are acceptable, but acknowledge this risk explicitly.
