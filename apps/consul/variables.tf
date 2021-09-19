###############################
##  VPC
#

variable "project" {
  description = "Google project name"
}

variable "region" {
  default = "australia-southeast-1"
}

variable "zone" {
  default = "australia-southeast-1a"
}

variable "deployment_name" {
  type = string
  default = "hashi-demo"
}

variable "subnet_cidr" {
  type = string
}

variable "labels" {
  type    = map(any)
  default = {}
}

###############################
##  Access
#

variable "ssh_user" {
  type = string
}

variable "ssh_key" {
  type = string
}

###############################
##  Instances Types
#

variable "bastion_instance_type" {
  default = "e2-standard-2"
  type    = string
}

variable "vault_instance_type" {
  default = "f1-micro"
  type    = string
}

variable "consul_instance_type" {
  default = "f1-micro"
  type    = string
}

variable "gke_instance_type" {
  default = "f1-micro"
  type    = string
}

###############################
##  Instances Images
#

variable "bastion_image_id" {
  default = "devopstower-soe"
  type    = string
}


variable "consul_image_id" {
  type = string
}

###############################
##  Key Management Service
#

variable "key_ring" {
  description = "Cloud KMS key ring name to create"
  default     = "test"
}

variable "crypto_key" {
  default     = "vault-test"
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  default = "global"
}

###############################
##  Licenses
#

variable "vault_license_path" {
  type = string
}

variable "consul_license_path" {
  type = string
}

