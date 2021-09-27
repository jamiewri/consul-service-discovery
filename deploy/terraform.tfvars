# VPC
project = "devopstower"

labels = {
  owner     = "jamiewright"
  se-region = "apj"
  terraform = "true"
  purpose   = "snapshot"
  ttl       = "24"

}

# Instances
preemptible_instances = false
bastion_image_id      = "bastion"
consul_image_id       = "consul-enterprise-soe-1-10-2"
web_image_id          = "web"

# Licenses
consul_license_path = "~/.licences/jamie-wright/consul.hclic"

# Web Server
web_target_size = 3
