module "networking" {
  source = "./modules/networking"
  
  project = var.project
  environment = var.environment
  ibm_region = var.ibm_region
  resource_group = var.resource_group
}