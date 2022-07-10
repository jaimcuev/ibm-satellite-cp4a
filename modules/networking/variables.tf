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

variable "zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Zonas de las subredes de la VPC"
}

variable "cidr_blocks" {
  type = list
  default = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "Rango de IPs por zona de la VPC"
}