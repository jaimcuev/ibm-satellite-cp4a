resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  name = "ssh-${var.project}-${var.environment}-001"
  public_key = tls_private_key.private_key.public_key_openssh
  resource_group = data.ibm_resource_group.resource_group.id
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
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.image
  vsi = var.controlplane_vsi
  type = "cp"

  depends_on = [module.networking]
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
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.image
  vsi = var.worker_vsi
  type = "worker"

  depends_on = [module.networking]
}

module "odf" {
  source = "./modules/host"
  
  project = var.project
  environment = var.environment
  ibm_region = var.ibm_region
  resource_group = var.resource_group
  vpc_id = module.networking.vpc_id
  vpc_subnets = module.networking.vpc_subnets
  profile = var.odf_profile
  ssh_key_id = ibm_is_ssh_key.ssh_key.id
  image = var.image
  vsi = var.odf_vsi
  type = "odf"

  depends_on = [module.networking]
}