resource "google_compute_instance_template" "consul" {
  name                      = "consul-${random_id.instance_id.hex}"
  labels                    = var.labels
  machine_type              = var.consul_instance_type

  disk {
      source_image = var.consul_image_id
      auto_delete  = true
      boot         = true
    }

  scheduling {
    preemptible = false
    automatic_restart = false
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_key} ${var.ssh_user} \n ${var.ssh_user}:${tls_private_key.bastion.public_key_openssh} ${var.ssh_user}"
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.consul.address
  }

  metadata_startup_script = <<SCRIPT
GCP_META_HOSTNAME=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
GCP_META_IPADDR_NIC0=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
sudo cat << EOF > /opt/consul/consul.d/consul.json
{
  "node_name": "$GCP_META_HOSTNAME",
  "ui_config":{
    "enabled": true
  },
  "addresses":{
    "http": "0.0.0.0"
  },
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "log_file": "/var/log/consul/consul.log",
  "domain": "consul",
  "datacenter": "devopstower",
  "bind_addr": "$GCP_META_IPADDR_NIC0",
  "advertise_addr": "$GCP_META_IPADDR_NIC0",
  "client_addr": "$GCP_META_IPADDR_NIC0",
  "ports": {
    "http": 8500,
    "dns": 8600
  },
  "server": true,
  "enable_syslog": true,
  "bootstrap_expect": 1,
  "start_join": ["$GCP_META_HOSTNAME"],
  "license_path": "/opt/consul/consul-license.hclic"
}
EOF
    echo -n ${file(var.consul_license_path)} >> /opt/consul/consul-license.hclic 2>&1
    sudo chown 750 /opt/consul/consul-license.hclic
    sudo chown consul:consul /opt/consul/consul-license.hclic
    sudo systemctl stop firewalld
    sleep 10
    sudo systemctl restart consul
    touch /home/packer/metadata-done
  SCRIPT
}

resource "google_compute_address" "consul" {
  provider     = google-beta
  name         = "consul"
  subnetwork   = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
}

resource "google_compute_region_instance_group_manager" "consul" {
  name               = "consul"
  region             = var.region
  base_instance_name = "consul-${random_id.instance_id.hex}"
  target_size        = 1
  wait_for_instances = true

  version {
    instance_template = google_compute_instance_template.consul.id
  }

  named_port {
    name = "http"
    port = 8500
  }
}

