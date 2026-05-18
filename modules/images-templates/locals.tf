locals {
  template_map = {
    cpanel     = "AlmaLinux 9 64-bit"
    docker     = "Ubuntu 24.04 LTS 64-bit"
    lamp       = "Ubuntu 24.04 LTS 64-bit"
    drupal     = "Ubuntu 24.04 LTS 64-bit"
    joomla     = "Ubuntu 24.04 LTS 64-bit"
    wordpress  = "Ubuntu 24.04 LTS 64-bit"
    wp-squared = "Ubuntu 24.04 LTS 64-bit"
    gitlab     = "Ubuntu 24.04 LTS 64-bit"
    jitsi      = "Ubuntu 24.04 LTS 64-bit"
    magento    = "Ubuntu 24.04 LTS 64-bit"
    minecraft  = "Ubuntu 24.04 LTS 64-bit"
    pritunl    = "Ubuntu 24.04 LTS 64-bit"
  }

  min_sizing = {
    cpanel     = { cpu = 2, ram_mb = 2048, disk_gb = 40 }
    docker     = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    lamp       = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    drupal     = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    joomla     = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    wordpress  = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
    wp-squared = { cpu = 2, ram_mb = 2048, disk_gb = 30 }
    gitlab     = { cpu = 4, ram_mb = 8192, disk_gb = 50 }
    jitsi      = { cpu = 2, ram_mb = 4096, disk_gb = 20 }
    magento    = { cpu = 4, ram_mb = 4096, disk_gb = 50 }
    minecraft  = { cpu = 2, ram_mb = 2048, disk_gb = 20 }
    pritunl    = { cpu = 1, ram_mb = 1024, disk_gb = 20 }
  }

  template_name = local.template_map[var.stack]
  stack_sizing  = local.min_sizing[var.stack]

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
