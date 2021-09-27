resource "google_compute_instance_template" "consul" {
  name         = "consul-${random_id.instance_id.hex}"
  labels       = var.labels
  machine_type = var.consul_instance_type

  disk {
    source_image = var.consul_image_id
    auto_delete  = true
    boot         = true
  }

  scheduling {
    preemptible       = var.preemptible_instances
    automatic_restart = false
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${tls_private_key.bastion.public_key_openssh} ${var.ssh_user}"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.consul.address
  }

  metadata_startup_script = templatefile("./templates/consul.sh.tftpl",
  { consul_license = local.consul_license })
}

resource "google_compute_address" "consul" {
  provider     = google-beta
  name         = "consul"
  subnetwork   = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
}

resource "google_compute_region_instance_group_manager" "consul" {
  name               = "consul"
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
