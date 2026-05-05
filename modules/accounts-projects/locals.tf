locals {
  account_role_ids = {
    for key, account in var.accounts :
    key => (
      account.role_key != null
      ? cloudstack_role.this[account.role_key].id
      : account.role_id
    )
  }
}
