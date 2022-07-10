variable "project" {
  default = "demo"
  description = "Nombre del proyecto"
}

variable "environment" {
  default = "dev"
  description = "Ambiente del proyecto"
}

variable "ibmcloud_api_key" {
  default = ""
  description = "IBM Cloud API Key"
}

variable "ibm_region" {
  description = "Región de la cuenta de IBM Cloud"
  default = "us-east"
}

variable "resource_group" {
  default = ""
  description = "Nombre del resource group donde se desea crear los recursos"
}

variable "controlplane_image" {
  default = "ibm-redhat-7-9-minimal-amd64-5"
  description = "Imagen que se usara para las VSIs del Control Plane"
}

variable "controlplane_profile" {
  default = "bx2-4x16"
  description = "Profile de la VSI para el Control Plane"
}

variable "controlplane_vsi" {
  type = list(object({
    zone = string
    volumes = list(number)
  }))
  default = [{
    zone = "us-east-1"
    volumes = []
  }, {
    zone = "us-east-2"
    volumes = []
  }, {
    zone = "us-east-3"
    volumes = []
  }]
  description = "Caracteristicas de las VSI a crear para el Control Plane"
}

variable "worker_image" {
  default = "ibm-redhat-7-9-minimal-amd64-5"
  description = "Imagen que se usara para las VSIs de los Workers"
}

variable "worker_profile" {
  default = "bx2-4x16"
  description = "Profile de la VSI para los Workers"
}

variable "worker_vsi" {
  type = list(object({
    zone = string
    volumes = list(number)
  }))
  default = [{
    zone = "us-east-1"
    volumes = [100, 500, 500]
  }, {
    zone = "us-east-2"
    volumes = [100, 500, 500]
  }, {
    zone = "us-east-3"
    volumes = [100, 500, 500]
  }]
  description = "Caracteristicas de las VSI a crear para los Workers"
}

variable "satellite_location_zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Nombres de las zonas para el Location de Satellite"
}

variable "satellite_managed_from" {
  default = "wdc"
  description = "Region de IBM Cloud para gestionar el Location de Satellite"
}

variable "satellite_resource_group" {
  default = ""
  description = "Nombre del resource group donde se desea crear los recursos de Satellite"
}

variable "satellite_ibmcloud_api_key" {
  default = ""
  description = "IBM Cloud API Key"
}