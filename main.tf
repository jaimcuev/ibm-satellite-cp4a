data "ibm_resource_group" "resourceGroup" {
  name = var.resource_group_name
}

resource "ibm_resource_instance" "activity_tracker" {
  name              = "activity_tracker"
  resource_group_id = data.ibm_resource_group.resourceGroup.id
  service           = "logdnaat"
  plan              = "lite"
  location          = "us-south"
}