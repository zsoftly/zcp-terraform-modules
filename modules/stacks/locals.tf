locals {
  template_map = {
    cpanel     = "AlmaLinux-9"
    docker     = "Ubuntu-24.04-LTS"
    lamp       = "Ubuntu-24.04-LTS"
    drupal     = "Ubuntu-24.04-LTS"
    joomla     = "Ubuntu-24.04-LTS"
    wordpress  = "Ubuntu-24.04-LTS"
    wp-squared = "Ubuntu-24.04-LTS"
    gitlab     = "Ubuntu-24.04-LTS"
    jitsi      = "Ubuntu-24.04-LTS"
    magento    = "Ubuntu-24.04-LTS"
    minecraft  = "Ubuntu-24.04-LTS"
    pritunl    = "Ubuntu-24.04-LTS"
  }

  min_sizing = {
    cpanel     = { cpu = 2, ram_mb = 2048, disk_gb = 40, service_offering = "CI1-4" }
    docker     = { cpu = 1, ram_mb = 1024, disk_gb = 20, service_offering = "CI1-1" }
    lamp       = { cpu = 1, ram_mb = 1024, disk_gb = 20, service_offering = "CI1-1" }
    drupal     = { cpu = 2, ram_mb = 2048, disk_gb = 20, service_offering = "CI1-4" }
    joomla     = { cpu = 2, ram_mb = 2048, disk_gb = 20, service_offering = "CI1-4" }
    wordpress  = { cpu = 1, ram_mb = 1024, disk_gb = 20, service_offering = "CI1-1" }
    wp-squared = { cpu = 2, ram_mb = 2048, disk_gb = 30, service_offering = "CI1-4" }
    gitlab     = { cpu = 4, ram_mb = 8192, disk_gb = 50, service_offering = "CI1-16" }
    jitsi      = { cpu = 2, ram_mb = 4096, disk_gb = 20, service_offering = "CI1-8" }
    magento    = { cpu = 4, ram_mb = 4096, disk_gb = 50, service_offering = "CI1-8" }
    minecraft  = { cpu = 2, ram_mb = 2048, disk_gb = 20, service_offering = "CI1-4" }
    pritunl    = { cpu = 1, ram_mb = 1024, disk_gb = 20, service_offering = "CI1-1" }
  }

  resolved_template_map = merge(local.template_map, var.template_name_overrides)
  template_name         = local.resolved_template_map[var.stack]
  stack_sizing          = local.min_sizing[var.stack]

  rendered_userdata = templatefile(
    "${path.module}/../../stacks/cloud-init/${var.stack}.tftpl",
    merge(
      var.stack_vars,
      {
        stack    = var.stack
        hostname = var.hostname
      }
    )
  )
}
