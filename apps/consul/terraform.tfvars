# Access
ssh_user = "packer"
ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD2rx1N/xzfqnP1jfW6Womv1ovpHmO6KYdOluPpBxHtQlrVyzJtiQYfmA3bmNWUc5fOIRghLD+sCUf24oubRn8IwPIM67h1UBCxsB1SwJGWxvljGI5roItQ7QooHrwrscykw4hNAdKyN7qmZC3WaohRJy65055WR2ueaZvKKAIrvd5iCZvbm65BCYG1NzkQMfHuk+9euJToiVKzcHf8CZsTGqR3+p+gwyH+Y11otYkovwUlR9Ds/TzbxCa18HtikCRil58RbNMg0gklXu1nQdJfw0VVO9cpx6QWrtbz64YDrciKMgKs1TojIrx3kUZw6MtML5RZ0iUQKe9M+2b69h5X"

# VPC
project         = "devopstower"
region          = "australia-southeast1"
zone            = "australia-southeast1-a"
deployment_name = "consul-service-registry"
subnet_cidr     = "10.10.1.0/24"
labels = {
  owner = "jamiewright"
  se-region = "apj"
  terraform = "true"
  purpose = "snapshot"
  ttl = "24"
  
}

# Instance
bastion_image_id = "devopstower-soe"
#consul_image_id  = "consul-enterprise-soe"
consul_image_id  = "consul-enterprise-soe-1-10-2"

bastion_instance_type = "e2-standard-2"
consul_instance_type  = "e2-small"

# Licenses
vault_license_path  = "~/.licences/jamie-wright/vault.hclic"
consul_license_path = "~/.licences/jamie-wright/consul.hclic"
