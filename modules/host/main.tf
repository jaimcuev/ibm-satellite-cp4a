data ibm_is_image "image_vm" {
  name = var.image
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

locals {
  volumes = flatten([
    for index, vsi in var.vsi: flatten([
      for volume in vsi.volumes: [{
        zone: vsi.zone
        vsi_index = index
        capacity = volume
      }]
    ])
  ])
}

resource "ibm_is_volume" "vpc_worker_volume" {
  count = length(local.volumes)
  name = "volumen-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
  profile = "10iops-tier"
  capacity = element(local.volumes, count.index).capacity
  resource_group = data.ibm_resource_group.resource_group.id
  zone = element(local.volumes, count.index).zone
}

resource "ibm_is_instance" "vpc_host_vsi" {
  count = length(var.vsi)
  
  name = "vsi-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
  image = data.ibm_is_image.image_vm.id
  profile = var.profile
  resource_group = data.ibm_resource_group.resource_group.id

  vpc = var.vpc_id
  zone = element(var.vsi, count.index).zone
  keys = [var.ssh_key_id]

  volumes = slice(ibm_is_volume.vpc_worker_volume.*.id, length(element(var.vsi, count.index).volumes) * count.index, length(element(var.vsi, count.index).volumes) * count.index + length(element(var.vsi, count.index).volumes) - 1)

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