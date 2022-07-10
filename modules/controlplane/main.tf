data ibm_is_image "image_vm" {
  name = var.image
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_is_instance" "vpc_controlplane_vsi" {
  count = length(var.vsi_zones)
  
  name = "vsi-${var.project}-cp-${var.environment}-${format("%03s", count.index + 1)}"
  image = data.ibm_is_image.image_vm.id
  profile = var.controlplane_profile
  resource_group = data.ibm_resource_group.resource_group.id

  primary_network_interface {
    subnet = var.vpc_subnets[index(var.vpc_subnets.*.zone, element(var.vsi_zones, count.index))].id
    allow_ip_spoofing = false
  }
  
  vpc = var.vpc_id
  zone = element(var.vsi_zones, count.index)
  keys = var.rhel_ssh_key_id
  tags = ["use:satloc"]

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}