output "template_ids" {
  description = "Registered template IDs keyed by input key."
  value       = module.images_templates.template_ids
}

output "template_names" {
  description = "Computed template names (including version suffix) keyed by input key."
  value       = module.images_templates.template_names
}

output "templates" {
  description = "Registered template details keyed by input key."
  value       = module.images_templates.templates
}
