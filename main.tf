resource "ibm_is_ssh_key" "rhel_ssh_key" {
  name = "ssh-key-${var.project}-${var.environment}-001"
  public_key = var.rhel_public_ssh_key
}