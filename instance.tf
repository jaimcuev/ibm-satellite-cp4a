data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "rhel_ssh_key" {
  name = "ssh-${var.project}-${var.environment}-001"
  public_key = tls_private_key.private_key.public_key_openssh
  resource_group = data.ibm_resource_group.resource_group.id
}