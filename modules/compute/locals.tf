locals {
  ssh_keypair_name = var.create_ssh_keypair ? cloudstack_ssh_keypair.this[0].name : var.ssh_keypair_name

  data_disks = merge([
    for inst_key, inst in var.instances : {
      for disk_key, disk in inst.data_disks :
      "${inst_key}-${disk_key}" => {
        instance_key  = inst_key
        disk_key      = disk_key
        name          = "${inst.name}-${disk_key}"
        disk_offering = disk.disk_offering
        size          = disk.size
        shrink_ok     = disk.shrink_ok
        device_id     = disk.device_id
      }
    }
  ]...)
}
