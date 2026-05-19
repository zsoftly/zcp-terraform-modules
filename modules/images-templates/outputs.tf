output "template_ids" {
  description = "Registered template IDs keyed by input key."
  value = {
    for key, tmpl in cloudstack_template.this : key => tmpl.id
  }
}

output "template_names" {
  description = "Computed template names (including version suffix) keyed by input key."
  value = {
    for key, tmpl in cloudstack_template.this : key => tmpl.name
  }
}

output "templates" {
  description = "Registered template details keyed by input key."
  value = {
    for key, tmpl in cloudstack_template.this : key => {
      id           = tmpl.id
      name         = tmpl.name
      display_text = tmpl.display_text
      is_public    = tmpl.is_public
      is_ready     = tmpl.is_ready
      zone         = var.zone
      project      = var.templates[key].project
    }
  }
}
