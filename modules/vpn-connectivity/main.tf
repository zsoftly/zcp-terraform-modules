resource "cloudstack_vpn_gateway" "this" {
  vpc_id = var.vpc_id
}

resource "cloudstack_vpn_customer_gateway" "this" {
  for_each = nonsensitive(toset(keys(var.customer_gateways)))

  name         = var.customer_gateways[each.key].name
  gateway      = var.customer_gateways[each.key].gateway
  cidr         = var.customer_gateways[each.key].cidr
  ipsec_psk    = var.customer_gateways[each.key].ipsec_psk
  esp_policy   = var.customer_gateways[each.key].esp_policy
  ike_policy   = var.customer_gateways[each.key].ike_policy
  dpd          = var.customer_gateways[each.key].dpd
  esp_lifetime = var.customer_gateways[each.key].esp_lifetime
  ike_lifetime = var.customer_gateways[each.key].ike_lifetime
  project      = var.project
}

resource "cloudstack_vpn_connection" "this" {
  for_each = nonsensitive(toset(keys(var.customer_gateways)))

  vpn_gateway_id      = cloudstack_vpn_gateway.this.id
  customer_gateway_id = cloudstack_vpn_customer_gateway.this[each.key].id
}
