data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_is_vpc" "vpc_vm" {
  name = "vpc-${var.project}-${var.environment}-001"
  resource_group = data.ibm_resource_group.resource_group.id
}

resource "ibm_is_public_gateway" "vpc_gateway" {
  count = 3
  name = "gateway-${var.project}-${var.environment}-${format("%03s", count.index + 1)}"
  vpc  = ibm_is_vpc.vpc_vm.id
  zone = "${var.ibm_region}-${count.index + 1}"
  resource_group = data.ibm_resource_group.resource_group.id
}

resource ibm_is_subnet "vpc_subnet" {
  count = 3
  name = "subnet-${var.project}-${var.environment}-${format("%03s", count.index + 1)}"
  vpc = ibm_is_vpc.vpc_vm.id
  zone = "${var.ibm_region}-${count.index + 1}"
  total_ipv4_address_count = 256
  resource_group = data.ibm_resource_group.resource_group.id
  public_gateway = element(ibm_is_public_gateway.vpc_gateway, count.index).id
}