# Terraform Code Notes

Explanations for non-obvious decisions in the Terraform source files. Organised by module/example.

---

## `modules/accounts-projects`

### `main.tf` — `cloudstack_account.this`

`for_each` requires a non-sensitive set. `var.accounts` is marked sensitive because it contains passwords, which makes the entire map sensitive — including the keys. `nonsensitive(toset(keys(...)))` unwraps only the keys (account names) for use as `for_each` identifiers. The account names themselves are not secret, so this is safe. The actual password values remain sensitive throughout.

### `main.tf` — `cloudstack_user.this`

Same reasoning as above. `var.users` is sensitive due to password fields. Only the map keys (user identifiers) are unwrapped via `nonsensitive()` for `for_each`. Passwords are never exposed.

---

## `modules/images-templates`

### `locals.tf` — `template_map`

Maps each stack slug to the CloudStack template name registered in ZCP. The string values must match the exact template names in your ZCP zone. Update them if templates are renamed or new OS versions are registered.

### `locals.tf` — `min_sizing`

Defines the minimum CPU, RAM (MB), and disk (GB) for each stack. Exposed via the `min_sizing` output so the calling compute resource can validate or enforce sizing before provisioning.

### `locals.tf` — `rendered_userdata`

Calls `templatefile()` with the stack's `.tftpl` file. `merge()` combines `var.stack_vars` (secrets and stack-specific config) with common variables (`stack`, `hostname`) so both are available as interpolation variables inside the template.

### `main.tf` — `data.cloudstack_template.this`

Looks up the existing OS template from CloudStack by name. `template_filter = "all"` is required by the provider schema — without it the plan fails with "missing required argument". Using `"all"` searches across featured, community, and self templates so any registered ZCP template is found regardless of visibility. The `filter` block matches on the template name resolved from `locals.template_map`. If the name does not exist in ZCP, `terraform plan` fails early with a clear error. The `project` argument is not supported by this data source — it is kept in `variables.tf` for use by future compute resources in this module.

---

## `examples/demo-stack`

### `main.tf` — `module.vpn_connectivity` vpc_id reference

`module.networking["demo"]` uses the hardcoded key `"demo"` which must match a key defined in `var.networking_vpcs` in `terraform.tfvars`. If the VPC key is changed in tfvars, this reference must be updated to match.
