# images-templates

Resolves the correct CloudStack OS template and renders cloud-init userdata for a selected application stack. Does **not** create VMs — outputs are consumed by a compute resource or the `demo-stack` example.

## Supported stacks

| Slug | Base OS | Min CPU | Min RAM | Min Disk |
|------|---------|---------|---------|----------|
| `cpanel` | AlmaLinux 9 | 2 | 2 GB | 40 GB |
| `docker` | Ubuntu 24.04 | 1 | 1 GB | 20 GB |
| `lamp` | Ubuntu 24.04 | 1 | 1 GB | 20 GB |
| `drupal` | Ubuntu 24.04 | 2 | 2 GB | 20 GB |
| `joomla` | Ubuntu 24.04 | 2 | 2 GB | 20 GB |
| `wordpress` | Ubuntu 24.04 | 1 | 1 GB | 20 GB |
| `wp-squared` | Ubuntu 24.04 | 2 | 2 GB | 30 GB |
| `gitlab` | Ubuntu 24.04 | 4 | 8 GB | 50 GB |
| `jitsi` | Ubuntu 24.04 | 2 | 4 GB | 20 GB |
| `magento` | Ubuntu 24.04 | 4 | 4 GB | 50 GB |
| `minecraft` | Ubuntu 24.04 | 2 | 2 GB | 20 GB |
| `pritunl` | Ubuntu 24.04 | 1 | 1 GB | 20 GB |

## Usage

```hcl
module "images_templates" {
  source   = "../../modules/images-templates"

  stack    = "wordpress"
  hostname = "wp01.prod.example.com"
  zone     = var.zone
  project  = var.project

  stack_vars = {
    mysql_root_password = var.mysql_root_password
    wp_admin_password   = var.wp_admin_password
    wp_admin_user       = var.wp_admin_user
    wp_admin_email      = var.wp_admin_email
    wp_site_title       = var.wp_site_title
  }
}

resource "cloudstack_instance" "app" {
  name      = "wp01"
  zone      = var.zone
  template  = module.images_templates.template_id
  user_data = module.images_templates.rendered_userdata
  # service_offering should satisfy module.images_templates.min_sizing
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `template_name` | CloudStack template name for the selected stack |
| `template_id` | CloudStack template ID for the selected stack |
| `stack` | The stack slug passed in |
| `rendered_userdata` | Base64-encoded cloud-init userdata **(sensitive)** |
| `min_sizing` | `{ cpu, ram_mb, disk_gb }` minimum requirements |

> `rendered_userdata` is marked `sensitive = true` and will not appear in `terraform plan` or `terraform apply` output.

## Adding a new stack

1. Add an entry to `template_map` in `locals.tf` with the exact CloudStack template name
2. Add an entry to `min_sizing` in `locals.tf`
3. Add the slug to the `validation` block in `variables.tf`
4. Create `zpcp/stacks/cloud-init/<slug>.tftpl` — copy `base.tftpl` as the starting point
