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

variable "vsi_zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Zona para cada VSI a crear"
}

variable "type" {
  default = "worker"
  description = "Tipo de VSI a crear"
}

variable "vsi_volumes" {
  type = list
  default = []
  description = "Capacidad de volumenes a asignar a la VSI"
}