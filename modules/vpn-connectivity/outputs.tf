output "vpn_gateway" {
  description = "VPN gateway details."
  value = {
    id        = cloudstack_vpn_gateway.this.id
    public_ip = cloudstack_vpn_gateway.this.public_ip
    vpc_id    = var.vpc_id
  }
}

output "customer_gateway_ids" {
  description = "Customer gateway IDs keyed by input key."
  value = {
    for key, gw in cloudstack_vpn_customer_gateway.this : key => gw.id
  }
}

output "customer_gateways" {
  description = "Customer gateway details including policy strings. Marked sensitive due to PSK."
  sensitive   = true
  value = {
    for key, gw in cloudstack_vpn_customer_gateway.this : key => {
      id           = gw.id
      name         = gw.name
      gateway      = gw.gateway
      cidr         = gw.cidr
      esp_policy   = gw.esp_policy
      ike_policy   = gw.ike_policy
      dpd          = gw.dpd
      esp_lifetime = gw.esp_lifetime
      ike_lifetime = gw.ike_lifetime
    }
  }
}

output "connection_ids" {
  description = "VPN connection IDs keyed by input key."
  value = {
    for key, conn in cloudstack_vpn_connection.this : key => conn.id
  }
}

output "connections" {
  description = "VPN connection details keyed by input key."
  value = {
    for key, conn in cloudstack_vpn_connection.this : key => {
      id                  = conn.id
      vpn_gateway_id      = conn.vpn_gateway_id
      customer_gateway_id = conn.customer_gateway_id
    }
  }
}
