resource "cloudstack_template" "this" {
  for_each = var.templates

  name         = local.template_names[each.key]
  display_text = local.template_display_texts[each.key]
  format       = each.value.format
  hypervisor   = each.value.hypervisor
  os_type      = each.value.os_type
  url          = each.value.url
  zone         = var.zone

  is_public        = each.value.is_public
  is_featured      = each.value.is_featured
  is_extractable   = each.value.is_extractable
  password_enabled = each.value.password_enabled
  for_cks          = each.value.for_cks

  is_ready_timeout = each.value.is_ready_timeout

  project = each.value.project != null ? each.value.project : var.project

  tags = local.template_tags[each.key]
}

check "template_names_unique" {
  assert {
    condition     = length(values(local.template_names)) == length(toset(values(local.template_names)))
    error_message = "Two or more templates resolve to the same computed name. Use distinct name and version combinations."
  }
}
