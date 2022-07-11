variable "project" {
  default = "demo"
  description = "Nombre del proyecto"
}

variable "environment" {
  default = "dev"
  description = "Ambiente del proyecto"
}

variable "ibm_region" {
  description = "Región de la cuenta de IBM Cloud"
  default = "us-east"
}

variable "resource_group" {
  default = ""
  description = "Nombre del resource group donde se desea crear los recursos"
}

variable "vpc_id" {
  type = string
  description = "ID del VPC"
}

variable "vpc_subnets" {
  type = list
  description = "Subnets del VPC"
}

variable "type" {
  default = "worker"
  description = "Tipo de VSI a crear"
}

variable "ssh_key_id" {
  type = string
  description = "ID de la llave SSH de RHEL"
}

variable "image" {
  default = "ibm-redhat-7-9-minimal-amd64-5"
  description = "Imagen que se usara para las VSIs"
}

variable "profile" {
  default = "bx2-4x16"
  description = "Profile de las VSI"
}

variable "vsi" {
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
  description = "Caracteristicas de las VSI a crear"
}