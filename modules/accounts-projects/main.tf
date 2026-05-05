resource "cloudstack_role" "this" {
  for_each = var.roles

  name        = each.value.name
  description = try(each.value.description, each.value.name)
  type        = each.value.role_type
}

resource "cloudstack_account" "this" {
  for_each = var.accounts

  account      = try(each.value.account, each.value.username)
  account_type = each.value.account_type
  email        = each.value.email
  first_name   = each.value.first_name
  last_name    = each.value.last_name
  username     = each.value.username
  password     = each.value.password
  domain_id    = try(each.value.domain_id, null)
  role_id      = local.account_role_ids[each.key]
}

resource "cloudstack_user" "this" {
  for_each = var.users

  username   = each.value.username
  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name
  password   = each.value.password
  account    = cloudstack_account.this[each.value.account_key].account
}

resource "cloudstack_project" "this" {
  for_each = var.projects

  name        = each.value.name
  displaytext = try(each.value.display_text, each.value.name)
  account     = each.value.account_key != null ? cloudstack_account.this[each.value.account_key].account : null
}
