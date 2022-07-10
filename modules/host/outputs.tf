output "hosts" {
  value = ibm_is_instance.vpc_host_vsi[*].name
}