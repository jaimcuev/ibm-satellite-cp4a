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