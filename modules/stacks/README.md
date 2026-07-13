# stacks

Selects an application stack, resolves the CloudStack OS template, and renders
cloud-init userdata for the selected stack.

This module does not create VMs. It produces `template_id` and
`rendered_userdata` for the calling compute resource to consume.

## Supported Stacks

`cpanel`, `docker`, `lamp`, `drupal`, `joomla`, `wordpress`, `wp-squared`,
`gitlab`, `jitsi`, `magento`, `minecraft`, `pritunl`

Default OS template names and minimum sizing are in `locals.tf`. Override any
template name with `template_name_overrides`.

## Usage

```hcl
module "stack" {
  source = "../../modules/stacks"

  stack    = "wordpress"
  hostname = "wp01.example.com"
  zone     = var.zone
}

resource "cloudstack_instance" "app" {
  name             = "wp01"
  zone             = var.zone
  template         = module.stack.template_id
  service_offering = "your-service-offering"
  user_data        = module.stack.rendered_userdata
}
```

Override the default template name when your zone uses a different registration:

```hcl
module "stack" {
  source = "../../modules/stacks"

  stack    = "docker"
  hostname = "docker01.example.com"
  zone     = var.zone

  template_name_overrides = {
    docker = "Ubuntu-24.04-custom"
  }
}
```

Pass secrets and per-VM config via `stack_vars`. All values are treated as
sensitive and will not appear in plan output. Never commit them to source
control — use `TF_VAR_*` environment variables or a secrets manager.

## Outputs

| Name                | Description                                                                             |
| ------------------- | --------------------------------------------------------------------------------------- |
| `template_id`       | CloudStack template ID resolved for the selected stack                                  |
| `template_name`     | CloudStack template name resolved for the selected stack                                |
| `stack`             | The stack slug passed in                                                                |
| `rendered_userdata` | Base64-encoded cloud-init userdata. Pass to `cloudstack_instance.user_data`. Sensitive. |
| `min_sizing`        | Minimum CPU, RAM (MB), and disk (GB) for the selected stack                             |
