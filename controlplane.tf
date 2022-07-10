module "controlplane" {
  source = "./modules/controlplane"
  
  ibm_region = var.ibm_region
  resource_group = var.resource_group
  project = var.project
  environment = var.environment
  vpc_id = module.networking.vpc_id
  vpc_subnets = module.networking.vpc_subnets
  profile = var.controlplane_profile
  vsi_zones = var.controlplane_vsi_zones
  rhel_ssh_key_id = ibm_is_ssh_key.rhel_ssh_key.id
  image = var.controlplane_image

  depends_on = [module.networking]
}