module "satellite-host" {
  source = "./modules/host"

  project = var.project
  environment = var.environment
  resource_group = var.satellite_resource_group
  ibmcloud_api_key = var.satellite_ibmcloud_api_key
  location = module.satellite-location.location_id
  host_vms = module.controlplane.instances
  location_zones = var.satellite_location_zones
}