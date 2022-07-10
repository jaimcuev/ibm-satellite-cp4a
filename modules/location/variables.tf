variable "ibmcloud_api_key" {
  default = ""
  description = "IBM Cloud API Key"
}

variable "project" {
  default = "demo"
  description = "Nombre del proyecto"
}

variable "environment" {
  default = "dev"
  description = "Ambiente del proyecto"
}

variable "resource_group" {
  default = ""
  description = "Nombre del resource group donde se desea crear los recursos"
}

variable "location_zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Nombres de las zonas para el Location de Satellite"
}

variable "managed_from" {
  default = "wdc"
  description = "Region de IBM Cloud para gestionar el Location de Satellite"
}