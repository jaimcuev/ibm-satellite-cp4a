locals {
  controlplane_volumes = [
    for zone, count in var.controlplane_vsi_zones: []
  ]
}

module "controlplane" {
  source = "./modules/host"
  
  project = var.project
  environment = var.environment
  ibm_region = var.ibm_region
  resource_group = var.resource_group
  vpc_id = module.networking.vpc_id
  vpc_subnets = module.networking.vpc_subnets
  profile = var.controlplane_profile
  vsi_zones = var.controlplane_vsi_zones
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.controlplane_image
  volumes = local.controlplane_volumes
  type = "cp"

  depends_on = [module.networking]
}