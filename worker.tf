resource "ibm_is_volume" "vpc_worker_volume" {
  count = length(var.worker_vsi_zones)
  name = "volumen-${var.project}-worker-${var.environment}-${format("%03s", count.index + 1)}"
  profile = "10iops-tier"
  capacity = 100
  resource_group = data.ibm_resource_group.resource_group.id
  zone = element(var.worker_vsi_zones, count.index)
}

locals {
  worker_volumes = flatten([
    for count in range(0, length(var.worker_vsi_zones)): [
      ibm_is_volume.vpc_worker_volume.*.id
    ]
  ])
}

module "worker" {
  source = "./modules/host"
  
  project = var.project
  environment = var.environment
  ibm_region = var.ibm_region
  resource_group = var.resource_group
  vpc_id = module.networking.vpc_id
  vpc_subnets = module.networking.vpc_subnets
  profile = var.worker_profile
  vsi_zones = var.worker_vsi_zones
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.worker_image
  volumes = local.worker_volumes
  type = "worker"

  depends_on = [module.networking]
}