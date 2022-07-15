data ibm_is_image "image_vm" {
  name = var.image
}

data "local_file" "reregister_vsi" {
  filename = "${path.module}/reregister-ng-rhel-vsi.sh"
}

data "local_file" "attach_sattelite_location" {
  filename = "${path.module}/attachHost-satellite-location.sh"
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "ibm_is_instance" "instance_vsi" {
  count = length(var.vsi)
  
  name = "vsi-${var.project}-${var.type}-${var.environment}-${format("%03s", count.index + 1)}"
  image = data.ibm_is_image.image_vm.id
  profile = var.profile
  resource_group = data.ibm_resource_group.resource_group.id

  vpc = var.vpc_id
  zone = element(var.vsi, count.index).zone
  keys = [var.ssh_key_id]

  primary_network_interface {
    subnet = var.vpc_subnets[index(var.vpc_subnets.*.zone, element(var.vsi, count.index).zone)].id
    allow_ip_spoofing = false
  }

    user_data = <<-EOUD
            #!/bin/bash
            echo '${data.local_file.reregister_vsi.content_base64}' | base64 --decode > /tmp/reregister-ng-rhel-vsi.sh
            echo '${data.local_file.attach_sattelite_location.content_base64}' | base64 --decode > /tmp/attachHost-satellite-location.sh
            cd /tmp
            chmod +x reregister-ng-rhel-vsi.sh
            ./reregister-ng-rhel-vsi.sh
            subscription-manager refresh
            subscription-manager repos --enable rhel-server-rhscl-7-rpms
            subscription-manager repos --enable rhel-7-server-optional-rpms
            subscription-manager repos --enable rhel-7-server-rh-common-rpms
            subscription-manager repos --enable rhel-7-server-supplementary-rpms
            subscription-manager repos --enable rhel-7-server-extras-rpms
            sudo nohup bash /tmp/attachHost-satellite-location.sh
            EOUD

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}