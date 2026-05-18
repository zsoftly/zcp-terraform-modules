locals {
  ubuntu_stacks = toset([
    "docker", "lamp", "drupal", "joomla", "wordpress",
    "wp-squared", "gitlab", "jitsi", "magento", "minecraft", "pritunl"
  ])
  is_ubuntu = contains(local.ubuntu_stacks, var.stack)
}

data "cloudstack_template" "this" {
  template_filter = local.is_ubuntu ? "featured" : "all"

  filter {
    name  = "name"
    value = local.template_name
  }
}
