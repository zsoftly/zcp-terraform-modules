locals {
  acs_vpn_policies = {
    esp = {
      aes256_sha256_modp2048 = "aes256-sha256;modp2048"
      aes128_sha1_modp1536   = "aes128-sha1;modp1536"
    }
    ike = {
      aes256_sha256_modp2048 = "aes256-sha256;modp2048"
      aes128_sha1_modp1536   = "aes128-sha1;modp1536"
    }
  }
}
