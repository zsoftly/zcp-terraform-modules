locals {
  account_role_ids = {
    for key, account in var.accounts :
    key => (
      account.role_key != null
      ? cloudstack_role.this[account.role_key].id
      : account.role_id
    )
  }

  account_domain_ids = {
    for key, account in var.accounts :
    key => (
      account.domain_key != null
      ? cloudstack_domain.this[account.domain_key].id
      : account.domain_id
    )
  }

  quota_type_names = {
    instances         = "instance"
    ips               = "ip"
    volumes           = "volume"
    snapshots         = "snapshot"
    templates         = "template"
    networks          = "network"
    vpcs              = "vpc"
    cpu               = "cpu"
    memory            = "memory"
    primary_storage   = "primary_storage"
    secondary_storage = "secondary_storage"
  }

  quota_field_values = {
    for qk, q in var.quotas : qk => {
      instances         = q.instances
      ips               = q.ips
      volumes           = q.volumes
      snapshots         = q.snapshots
      templates         = q.templates
      networks          = q.networks
      vpcs              = q.vpcs
      cpu               = q.cpu
      memory            = q.memory
      primary_storage   = q.primary_storage
      secondary_storage = q.secondary_storage
    }
  }

  quota_limits = merge([
    for qk, q in var.quotas : {
      for type_name, type_str in local.quota_type_names :
      "${qk}-${type_name}" => {
        account_key = qk
        type        = type_str
        max         = local.quota_field_values[qk][type_name]
      }
      if local.quota_field_values[qk][type_name] != null
    }
  ]...)
}
