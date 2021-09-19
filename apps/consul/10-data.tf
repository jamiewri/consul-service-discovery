data "http" "myip_json" {
  url = "https://ifconfig.co/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  myip = "${jsondecode(data.http.myip_json.body).ip}/32"
}

resource "random_id" "instance_id" {
  byte_length = 2
}
