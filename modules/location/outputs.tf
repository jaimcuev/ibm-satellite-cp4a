output "location_id" {
  value = data.ibm_satellite_location.location.id
}

output "location_crn" {
  value = data.ibm_satellite_location.location.crn
}

output "host_script" {
  value = data.ibm_satellite_attach_host_script.script.host_script
}