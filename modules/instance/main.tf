data ibm_is_image "image_vm" {
  name = var.image
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_is_instance" "instance_vsi" {
  count = length(var.vsi)
  
  name = "vsi-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
  image = data.ibm_is_image.image_vm.id
  profile = var.profile
  resource_group = data.ibm_resource_group.resource_group.id

  vpc = var.vpc_id
  zone = element(var.vsi, count.index).zone
  keys = [var.ssh_key_id]

  primary_network_interface {
    subnet = var.vpc_subnets[index(var.vpc_subnets.*.zone, element(var.vsi, count.index).zone)].id
    allow_ip_spoofing = false
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}