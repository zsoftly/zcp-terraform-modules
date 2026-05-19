data "cloudstack_template" "this" {
  template_filter = "executable"

  filter {
    name  = "name"
    value = local.template_name
  }
}
