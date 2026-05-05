locals {
  public_ip_ids = merge(
    var.existing_public_ip_ids,
    {
      for key, ip in cloudstack_ipaddress.this : key => ip.id
    }
  )

  public_ip_addresses = {
    for key, ip in cloudstack_ipaddress.this : key => ip.ip_address
  }
}
