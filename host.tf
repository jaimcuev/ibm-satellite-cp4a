module "satellite-host" {
  source = "./modules/host"

  location = module.satellite-location.location_id
  host_vms = module.controlplane.instances
  location_zones = var.satellite_location_zones

  depends_on = [
    module.controlplane
  ]
}