resource "google_compute_instance_template" "compute" {
  name                      = "web-${random_id.instance_id.hex}"
  labels                    = var.labels
  machine_type              = var.consul_instance_type

  disk {
      source_image = var.consul_image_id
      auto_delete  = true
      boot         = true
    }

  scheduling {
    preemptible = true
    automatic_restart = false
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_key} ${var.ssh_user} \n ${var.ssh_user}:${tls_private_key.bastion.public_key_openssh} ${var.ssh_user}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.web.address
  }

  metadata_startup_script = <<SCRIPT
GCP_META_HOSTNAME=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
GCP_META_IPADDR_NIC0=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
sudo cat << EOF > /opt/consul/consul.d/consul.json
{
  "datacenter":"devopstower",
  "data_dir":"/opt/consul",
  "log_level":"INFO",
  "node_name":"example",
  "start_join":["${google_dns_record_set.consul-internal.name}"],
  "bind_addr":"{{GetInterfaceIP \"eth0\"}}",
  "node_meta": {
    "instance_something":"jamie",
    "network":"hightrust"
  }
}
EOF
    sleep 10
    sudo systemctl restart consul
    sudo systemctl stop firewalld
    touch /home/packer/metadata-done
  SCRIPT
}

resource "google_compute_address" "web" {
  provider     = google-beta
  name         = "web"
  subnetwork   = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
}

resource "google_compute_region_instance_group_manager" "web" {
  name               = "web"
  region             = var.region
  base_instance_name = "web-${random_id.instance_id.hex}"
  target_size        = 2
  wait_for_instances = true

  version {
    instance_template = google_compute_instance_template.compute.id
  }

  named_port {
    name = "http"
    port = 80
  }
}
