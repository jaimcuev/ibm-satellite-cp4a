data "ibm_resource_group" "resourceGroup" {
  name = var.resource_group_name
}

resource "ibm_resource_instance" "cos_instance" {
  name              = "cos-instance-demo"
  resource_group_id = data.ibm_resource_group.resourceGroup.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
}
