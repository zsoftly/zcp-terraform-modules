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

  project = each.value.project

  tags = local.template_tags[each.key]
}
