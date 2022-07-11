resource "ibm_satellite_host" "assign_host" {
  count         = length(var.host_vms)

  location      = var.location
  host_id       = element(var.host_vms, count.index)
  zone          = element(var.location_zones, count.index)
  host_provider = "ibm"
}