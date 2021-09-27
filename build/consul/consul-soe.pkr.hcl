variable "ssh_user" {
  type    = string
  default = "packer"
}

variable "project" {
  type = string
  default = env("GCP_PROJECT")
}

source "googlecompute" "consul" {
  image_name = "consul-enterprise-soe-1-10-2"
  project_id   = var.project
  source_image = "centos-8-v20201216"
  ssh_username = "packer"
  zone         = "australia-southeast1-a"
}

build {
  sources = ["source.googlecompute.consul"]

  provisioner "shell" {
    inline = ["sleep 30", "sudo yum install epel-release -y", "sudo yum install ansible -y"]
  }
  provisioner "file" {
    destination = "/home/packer"
    source      = "./ansible"
  }
  provisioner "shell" {
    inline = ["ansible-playbook -c local ./ansible/configure.yaml"]
  }
}
