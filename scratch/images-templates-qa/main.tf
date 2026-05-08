module "images_templates" {
  source = "../../modules/images-templates"

  zone      = var.zone
  tags      = var.tags
  templates = var.templates
}
