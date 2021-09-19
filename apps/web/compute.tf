resource "google_compute_instance_template" "compute" {
  name                      = "web"
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
    sshKeys = "${var.ssh_user}:${var.ssh_key} ${var.ssh_user}"
  }
  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = <<SCRIPT
GCP_META_HOSTNAME=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
GCP_META_IPADDR_NIC0=$(curl -s  -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
sudo cat << EOF > /opt/consul/consul.d/consul.json
{
  "datacenter":"devopstower",
  "data_dir":"/opt/consul",
  "log_level":"INFO",
  "node_name":"$GCP_META_HOSTNAME",
  "start_join":["10.10.1.18"],
  "bind_addr":"{{GetInterfaceIP \"eth0\"}}",
  "node_meta": {
    "instance_something":"jamie",
    "network":"hightrust"
  },
  "license_path": "/opt/consul/consul-license.hclic"
}
EOF
sudo cat << EOF > /opt/consul/consul.d/web.json
{
  "service": {
    "name": "web",
    "tags": [
      "frontend"
    ],
    "port": 80
  }
}
EOF
    echo -n ${file(var.consul_license_path)} >> /opt/consul/consul-license.hclic 2>&1
    sudo chown 750 /opt/consul/consul-license.hclic
    sudo chown consul:consul /opt/consul/consul-license.hclic
    sleep 10
    sudo systemctl restart consul
    sudo systemctl stop firewalld
    touch /home/packer/metadata-done
  SCRIPT
}

resource "google_compute_region_instance_group_manager" "web" {
  name               = "web"
  region             = var.region
  base_instance_name = "web"
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
