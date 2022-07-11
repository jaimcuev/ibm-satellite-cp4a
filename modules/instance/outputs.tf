output "instances" {
  value = ibm_is_instance.instance_vsi[*].name
}