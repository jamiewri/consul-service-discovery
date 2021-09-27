variable "ssh_user" {
  type    = string
  default = "packer"
}

variable "project" {
  type = string
  default = env("GCP_PROJECT")
}

source "googlecompute" "soe" {
  image_name = "bastion"
  project_id   = var.project
  source_image = "centos-8-v20201216"
  ssh_username = "packer"
  zone         = "australia-southeast1-a"
}

build {
  sources = ["source.googlecompute.soe"]

  provisioner "shell" {
    inline = ["sleep 30", "sudo yum install epel-release -y", "sudo yum install ansible -y"]
  }
  provisioner "ansible-local" {
    playbook_file = "./configure.yaml"
  }
}
