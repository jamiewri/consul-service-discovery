resource "google_compute_instance_template" "web" {
  name         = "web"
  labels       = var.labels
  machine_type = var.web_instance_type
  depends_on   = [google_compute_region_instance_group_manager.consul]

  disk {
    source_image = var.web_image_id
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
    subnetwork = google_compute_subnetwork.subnet.id
  }

  metadata_startup_script = templatefile("./templates/web.sh.tftpl",
    { consul_license = local.consul_license
  consul_internal_address = google_compute_address.consul-internal.address })

}

resource "google_compute_region_instance_group_manager" "web" {
  name               = "web"
  base_instance_name = "web"
  target_size        = var.web_target_size
  wait_for_instances = true

  version {
    instance_template = google_compute_instance_template.web.id
  }

  named_port {
    name = "http"
    port = 80
  }
}
