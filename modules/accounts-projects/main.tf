resource "cloudstack_domain" "this" {
  for_each = var.domains

  name             = each.value.name
  parent_domain_id = each.value.parent_domain_id
  network_domain   = each.value.network_domain
}

resource "cloudstack_role" "this" {
  for_each = var.roles

  name        = each.value.name
  description = coalesce(each.value.description, each.value.name)
  type        = each.value.role_type
}

resource "cloudstack_account" "this" {
  for_each = nonsensitive(toset(keys(var.accounts)))

  account      = try(var.accounts[each.key].account, var.accounts[each.key].username)
  account_type = var.accounts[each.key].account_type
  email        = var.accounts[each.key].email
  first_name   = var.accounts[each.key].first_name
  last_name    = var.accounts[each.key].last_name
  username     = var.accounts[each.key].username
  password     = var.accounts[each.key].password
  domain_id    = local.account_domain_ids[each.key]
  role_id      = local.account_role_ids[each.key]
}

resource "cloudstack_user" "this" {
  for_each = nonsensitive(toset(keys(var.users)))

  username   = var.users[each.key].username
  email      = var.users[each.key].email
  first_name = var.users[each.key].first_name
  last_name  = var.users[each.key].last_name
  password   = var.users[each.key].password
  account    = cloudstack_account.this[nonsensitive(var.users[each.key].account_key)].account
}

resource "cloudstack_project" "this" {
  for_each = var.projects

  name        = each.value.name
  displaytext = try(each.value.display_text, each.value.name)
  account     = each.value.account_key != null ? cloudstack_account.this[each.value.account_key].account : null
}

resource "cloudstack_limits" "this" {
  for_each = local.quota_limits

  type    = each.value.type
  max     = each.value.max
  account = cloudstack_account.this[each.value.account_key].account
}
