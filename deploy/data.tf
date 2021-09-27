data "http" "myip_json" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  myip           = "${jsondecode(data.http.myip_json.body).ip}/32"
  consul_license = file(var.consul_license_path)
}

resource "random_id" "instance_id" {
  byte_length = 2
}
