locals {
  template_names = {
    for k, t in var.templates :
    k => t.version != null ? "${t.name}-v${t.version}" : t.name
  }

  template_display_texts = {
    for k, t in var.templates :
    k => coalesce(t.display_text, local.template_names[k])
  }

  template_tags = {
    for k, t in var.templates :
    k => merge(
      var.tags,
      t.tags,
      t.version != null ? { version = t.version } : {}
    )
  }
}
