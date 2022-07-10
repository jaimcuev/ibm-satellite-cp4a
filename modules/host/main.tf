data ibm_is_image "image_vm" {
  name = var.image
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

locals {
  volumes = concat([
    for zone in var.vsi_zones: [
      for volume in var.vsi_volumes: [
        {
          name: "vsi-volume-" + zone + "-" + str(volume),
          capacity: volume,
          zone: zone,
        },
      ]
    ]
  ])
}

resource "ibm_is_volume" "vpc_worker_volume" {
  count = length(local.volumes)
  name = "volumen-${var.project}-worker-${var.environment}-${format("%03s", count.index + 1)}"
  profile = "10iops-tier"
  capacity = element(local.volumes, count.index).capacity
  resource_group = data.ibm_resource_group.resource_group.id
  zone = element(local.volumes, count.index).zone
}

# resource "ibm_is_instance" "vpc_host_vsi" {
#   count = length(var.vsi_zones)
  
#   name = "vsi-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
#   image = data.ibm_is_image.image_vm.id
#   profile = var.profile
#   resource_group = data.ibm_resource_group.resource_group.id

#   vpc = var.vpc_id
#   zone = element(var.vsi_zones, count.index)
#   keys = [var.ssh_key_id]
#   volumes = element(var.vsi_volumes, count.index)

#   primary_network_interface {
#     subnet = var.vpc_subnets[index(var.vpc_subnets.*.zone, element(var.vsi_zones, count.index))].id
#     allow_ip_spoofing = false
#   }

#   timeouts {
#     create = "15m"
#     update = "15m"
#     delete = "15m"
#   }
# }