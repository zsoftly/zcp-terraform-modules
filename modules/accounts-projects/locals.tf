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
    instances         = "0"
    ips               = "1"
    volumes           = "2"
    snapshots         = "3"
    templates         = "4"
    networks          = "6"
    vpcs              = "7"
    cpu               = "8"
    memory            = "9"
    primary_storage   = "10"
    secondary_storage = "11"
  }

  quota_limits = merge([
    for qk, q in var.quotas : {
      for type_name, type_str in local.quota_type_names :
      "${qk}-${type_name}" => {
        account_key = qk
        type        = type_str
        max = (
          type_name == "instances" ? q.instances :
          type_name == "ips" ? q.ips :
          type_name == "volumes" ? q.volumes :
          type_name == "snapshots" ? q.snapshots :
          type_name == "templates" ? q.templates :
          type_name == "networks" ? q.networks :
          type_name == "vpcs" ? q.vpcs :
          type_name == "cpu" ? q.cpu :
          type_name == "memory" ? q.memory :
          type_name == "primary_storage" ? q.primary_storage :
          type_name == "secondary_storage" ? q.secondary_storage :
          null
        )
      }
      if(
        type_name == "instances" ? q.instances != null :
        type_name == "ips" ? q.ips != null :
        type_name == "volumes" ? q.volumes != null :
        type_name == "snapshots" ? q.snapshots != null :
        type_name == "templates" ? q.templates != null :
        type_name == "networks" ? q.networks != null :
        type_name == "vpcs" ? q.vpcs != null :
        type_name == "cpu" ? q.cpu != null :
        type_name == "memory" ? q.memory != null :
        type_name == "primary_storage" ? q.primary_storage != null :
        type_name == "secondary_storage" ? q.secondary_storage != null :
        false
      )
    }
  ]...)
}
