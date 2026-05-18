data "cloudstack_template" "this" {
  filter {
    name  = "name"
    value = local.template_name
  }

  filter {
    name  = "zone"
    value = var.zone
  }

  project = var.project
}
