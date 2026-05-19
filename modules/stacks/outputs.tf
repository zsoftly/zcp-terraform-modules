output "template_name" {
  description = "CloudStack template name resolved for the selected stack."
  value       = data.cloudstack_template.this.name
}

output "template_id" {
  description = "CloudStack template ID resolved for the selected stack."
  value       = data.cloudstack_template.this.id
}

output "stack" {
  description = "The stack slug passed in, for reference by the calling module."
  value       = var.stack
}

output "rendered_userdata" {
  description = "Base64-encoded cloud-init userdata for the selected stack. Pass directly to cloudstack_instance.user_data."
  value       = base64encode(local.rendered_userdata)
  sensitive   = true
}

output "min_sizing" {
  description = "Minimum CPU, RAM (MB), and disk (GB) for the selected stack. The calling compute resource should enforce these."
  value       = local.stack_sizing
}
