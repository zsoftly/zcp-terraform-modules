output "instances" {
  description = "Created instance details keyed by input key."
  value = {
    for key, instance in cloudstack_instance.this : key => {
      id           = instance.id
      name         = instance.name
      display_name = instance.display_name
      ip_address   = instance.ip_address
      network_id   = instance.network_id
      group        = instance.group
      tags         = instance.tags
    }
  }
}

output "instance_ids" {
  description = "Created instance IDs keyed by input key."
  value = {
    for key, instance in cloudstack_instance.this : key => instance.id
  }
}

output "instance_ips" {
  description = "Primary IP addresses keyed by input key."
  value = {
    for key, instance in cloudstack_instance.this : key => instance.ip_address
  }
}

output "instance_passwords" {
  description = "Generated passwords for password-enabled templates, keyed by input key. Null for SSH-key templates."
  value = {
    for key, instance in cloudstack_instance.this : key => instance.password
  }
  sensitive = true
}

output "ssh_keypair" {
  description = "SSH keypair details, or null when no keypair is managed by this module."
  value = var.create_ssh_keypair ? {
    name        = cloudstack_ssh_keypair.this[0].name
    fingerprint = cloudstack_ssh_keypair.this[0].fingerprint
  } : null
}

output "affinity_groups" {
  description = "Created affinity groups keyed by input key."
  value = {
    for key, group in cloudstack_affinity_group.this : key => {
      id   = group.id
      name = group.name
      type = group.type
    }
  }
}

output "data_disks" {
  description = "Created data disks keyed by \"<instance_key>-<disk_key>\"."
  value = {
    for key, disk in cloudstack_disk.this : key => {
      id                 = disk.id
      name               = disk.name
      size               = disk.size
      device_id          = disk.device_id
      virtual_machine_id = disk.virtual_machine_id
    }
  }
}
