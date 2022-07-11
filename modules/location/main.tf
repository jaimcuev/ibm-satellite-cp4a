data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_resource_instance" "cos_instance" {
  name = "cos-${var.project}-${var.environment}-001"
  resource_group_id = data.ibm_resource_group.resource_group.id
  service = "cloud-object-storage"
  plan = "standard"
  location = "global"
}

resource "ibm_satellite_location" "create_location" {
  location = "location-${var.project}-${var.environment}-001"
  zones = var.location_zones
  managed_from = var.managed_from
  resource_group_id = data.ibm_resource_group.resource_group.id

  timeouts {
    create = "60m"
    update = "30m"
    delete = "60m"
  }
}

resource "ibm_cos_bucket" "cos_bucket" {
  bucket_name = "cos-sat-terraform"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  satellite_location_id = ibm_satellite_location.create_location.id
  
  object_versioning {
    enable  = true
  }

  expire_rule {
    rule_id = "bucket-tf-rule1"
    enable  = false
    days    = 20
    prefix  = "logs/"
  }
}

data "ibm_satellite_location" "location" {
  location = ibm_satellite_location.create_location.id
  depends_on = [ibm_satellite_location.create_location]
}

data "ibm_satellite_attach_host_script" "script" {
  location = data.ibm_satellite_location.location.id
  host_provider = "ibm"
}