# The module requires an admin key (or password). The test pool needs no SSH
# access, so we generate a throwaway key rather than manage one. If debugging
# ever needs SSH, the private key is available in state.
resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
