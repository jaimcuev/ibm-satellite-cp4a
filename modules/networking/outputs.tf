output "vpc_id" {
  value = ibm_is_vpc.vpc_vm.id
}

output "vpc_subnets" {
  value = ibm_is_subnet.vpc_subnet
}