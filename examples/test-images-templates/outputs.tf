output "template_name" {
  value = module.images_templates.template_name
}

output "stack" {
  value = module.images_templates.stack
}

output "min_sizing" {
  value = module.images_templates.min_sizing
}

output "vpc_source_nat_ip" {
  value = module.networking.vpc.source_nat_ip
}

output "instance_id" {
  value = cloudstack_instance.test.id
}

output "instance_ip" {
  value = cloudstack_instance.test.ip_address
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/<your-key> -p 2222 ubuntu@${module.networking.vpc.source_nat_ip}"
}
