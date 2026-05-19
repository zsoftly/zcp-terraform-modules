# images-templates

Manages the lifecycle of CloudStack templates: registration, versioning, sharing, and deletion.

## Usage

```hcl
module "images_templates" {
  source = "../../modules/images-templates"

  zone = "yow-1"

  tags = {
    service = "zcp"
    managed = "terraform"
  }

  templates = {
    ubuntu_2204_v1 = {
      name       = "ubuntu-22.04"
      version    = "1.0.0"
      url        = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
      os_type    = "Ubuntu 22.04 LTS"
      format     = "QCOW2"
      hypervisor = "KVM"
      is_public  = false
    }
  }
}
```

## Versioning strategy

Set `version` on each template entry. The module appends `-v<version>` to the resource name
and writes the version into the template tags. To publish a new version, add a new map key
(e.g. `ubuntu_2204_v2`) without removing the old one. Remove the old key only once consumers
have migrated.

Any change to a replacement-driving field (`url`, `format`, `hypervisor`, `os_type`) will
destroy and recreate the template. Treat these changes as a new version: add a new map key
with a bumped version and migrate consumers before removing the old key. Do not rely on
in-place replacement for managed templates.

## Sharing

| Requirement | How |
|---|---|
| Available to all accounts in the zone | `is_public = true` |
| Restricted to a single project | `project = "project-name"` |
| Per-account sharing | Not supported by provider v0.6 — use CloudStack UI or API (`updateTemplatePermissions`) |

## File uploads

The CloudStack provider registers templates from an accessible URL (HTTP or HTTPS). To upload
a local file, stage it to an HTTP server, S3-compatible store, or internal mirror first, then
pass the resulting URL to the `url` argument.

**Security note:** Use HTTPS URLs wherever possible. HTTP URLs allow a man-in-the-middle to
substitute the disk image in transit. On private management networks with no external exposure,
HTTP mirrors are acceptable, but the risk should be acknowledged explicitly.

## Deletion

Remove the key from the `templates` map and run `terraform apply`. Terraform destroys the
template automatically.

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `zone` | CloudStack zone name or ID | `string` | — | yes |
| `tags` | Tags applied to all templates | `map(string)` | `{}` | no |
| `project` | Default CloudStack project to scope all templates | `string` | `null` | no |
| `templates` | Map of templates to register | `map(object(...))` | `{}` | no |

### `templates` object attributes

| Attribute | Description | Default |
|---|---|---|
| `name` | Base template name | required |
| `url` | Source URL for registration | required |
| `os_type` | CloudStack OS type name | required |
| `version` | Version string; appended as `-v<version>` suffix | `null` |
| `display_text` | Human-readable name (defaults to computed name) | `null` |
| `format` | Disk format: QCOW2, RAW, VHD, OVA, ISO, VHDX, BAREMETAL | `"QCOW2"` |
| `hypervisor` | Target hypervisor: KVM, VMware, XenServer, BareMetal, Simulator, Hyperv, LXC | `"KVM"` |
| `is_public` | Available to all accounts in the zone | `false` |
| `is_featured` | Mark as a featured template | `false` |
| `is_extractable` | Allow extraction | `false` |
| `password_enabled` | Enable password reset on first boot | `false` |
| `for_cks` | Mark template as eligible for CloudStack Kubernetes Service | `false` |
| `is_ready_timeout` | How long to wait for the template to become ready after registration | `"30m"` |
| `project` | Restrict to a CloudStack project | `null` |
| `tags` | Per-template tags (merged with module-level tags) | `{}` |

## Outputs

| Name | Description |
|---|---|
| `template_ids` | Map of key → template ID |
| `template_names` | Map of key → computed name (with version suffix) |
| `templates` | Map of key → `{ id, name, display_text, is_public, is_ready, zone, project }` |

## Notes

The `template_names_unique` check produces a warning at plan time if two entries resolve to
the same computed name. It does not block apply — the failure will surface at the CloudStack
API level. Use distinct `name` and `version` combinations to avoid this.
