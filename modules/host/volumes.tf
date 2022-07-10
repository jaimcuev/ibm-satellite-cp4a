locals {
  volumes = flatten([
    for index, vsi in var.vsi: flatten([
      for volume in vsi.volumes: [{
        instance = ibm_is_instance.vpc_host_vsi[index].id
        capacity = volume
      }]
    ])
  ])
}

resource "ibm_is_instance_volume_attachment" "example" {
  count = length(local.volumes)

  instance = element(local.volumes, count.index).instance

  name = "att-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
  profile = "10iops-tier"
  capacity = element(local.volumes, count.index).capacity
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete = true
  volume_name = "vol-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"

  depends_on = [
    ibm_is_instance.vpc_host_vsi
  ]

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}