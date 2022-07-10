output "controlplane_hosts" {
  value = ibm_is_instance.vpc_controlplane_vsi[*].name
}