module "worker" {
  source = "./modules/host"
  
  project = var.project
  environment = var.environment
  ibm_region = var.ibm_region
  resource_group = var.resource_group
  vpc_id = module.networking.vpc_id
  vpc_subnets = module.networking.vpc_subnets
  profile = var.worker_profile
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.worker_image
  vsi = var.worker_vsi
  type = "worker"

  depends_on = [module.networking]
}