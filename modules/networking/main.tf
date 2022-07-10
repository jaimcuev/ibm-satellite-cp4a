data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_is_vpc" "vpc_vm" {
  name = "vpc-${var.project}-${var.environment}-001"
  resource_group = data.ibm_resource_group.resource_group.id
}
