###############################
##  VPC
#

variable "project" {
  description = "Google project name"
}

variable "region" {
  description = "Google region"
  default     = "australia-southeast1"
}

variable "zone" {
  description = "Google zone"
  default     = "australia-southeast1-a"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "deployment_name" {
  type    = string
  default = "consul-service-discovery"
}

variable "labels" {
  type    = map(any)
  default = {}
}

###############################
##  Access
#

variable "ssh_user" {
  type    = string
  default = "packer"
}

variable "ssh_key" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

###############################
##  Instances Types
#

variable "bastion_instance_type" {
  type    = string
  default = "e2-small"
}

variable "web_instance_type" {
  type    = string
  default = "e2-small"
}

variable "consul_instance_type" {
  type    = string
  default = "e2-small"
}

variable "preemptible_instances" {
  description = "Provision this lab with preemptible instance types"
  type        = bool
  default     = true
}

###############################
##  Instances Images
#

variable "bastion_image_id" {
  type    = string
  default = "devopstower-soe"
}

variable "consul_image_id" {
  type = string
  default = "consul"
}

variable "web_image_id" {
  type = string
  default = "web"
}

###############################
##  Licenses
#

variable "consul_license_path" {
  description = "The path to where on your local filesystems to Consul Enterprise license."
  type = string
}

###############################
##  Web Server
#

variable "web_target_size" {
  description = "The number of replicas in the web server instance group"
  type    = number
  default = 1
}
