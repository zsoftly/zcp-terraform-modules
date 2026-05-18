module "images_templates" {
  source = "../../modules/images-templates"

  stack                   = var.stack
  hostname                = var.hostname
  zone                    = var.zone
  stack_vars              = var.stack_vars
  template_name_overrides = var.template_name_overrides
}
