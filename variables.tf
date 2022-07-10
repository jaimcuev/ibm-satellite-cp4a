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

variable "rhel_public_ssh_key" {
  default = ""
  description = "Llave SSH publica para VSIs de RHEL" 
}

variable "vpc_zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Zonas de las subredes de la VPC"
}

variable "vpc_cidr_blocks" {
  type = list
  default = ["10.241.0.0/18", "10.241.64.0/18", "10.241.128.0/18"]
  description = "Rango de IPs por zona de la VPC"
}

variable "controlplane_image" {
  default = "ibm-redhat-7-9-minimal-amd64-5"
  description = "Imagen que se usara para las VSIs del Control Plane"
}

variable "controlplane_profile" {
  default = "bx2-4x16"
  description = "Profile de la VSI para el Control Plane"
}

variable "controlplane_vsi_zones" {
  type = list
  default = ["us-east-1", "us-east-2", "us-east-3"]
  description = "Zona para cada VSI a crear para el Control Plane"
}
