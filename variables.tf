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

variable "image" {
  default = "ibm-redhat-7-9-minimal-amd64-5"
  description = "Imagen que se usara para las VSIs"
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

variable "worker_profile" {
  default = "gx2-8x64x1v100"
  description = "Profile de la VSI para los Workers"
}

variable "worker_vsi" {
  type = list(object({
    zone = string
    volumes = list(number)
  }))
  default = [{
    zone = "us-east-1"
    volumes = [100]
  }, {
    zone = "us-east-2"
    volumes = [100]
  }, {
    zone = "us-east-3"
    volumes = [100]
  }]
  description = "Caracteristicas de las VSI a crear para los Workers"
}

variable "odf_profile" {
  default = "bx2-16x64"
  description = "Profile de la VSI para los Workers de ODF"
}

variable "odf_vsi" {
  type = list(object({
    zone = string
    volumes = list(number)
  }))
  default = [{
    zone = "us-east-1"
    volumes = [100, 500]
  }, {
    zone = "us-east-2"
    volumes = [100, 500]
  }, {
    zone = "us-east-3"
    volumes = [100, 500]
  }]
  description = "Caracteristicas de las VSI a crear para los Workers de ODF"
}