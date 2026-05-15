module "images_templates" {
  source = "../../modules/images-templates"

  zone      = var.zone
  project   = var.project
  tags      = var.tags
  templates = var.templates
}
