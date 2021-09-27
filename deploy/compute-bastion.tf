resource "google_compute_instance" "bastion" {
  name                      = "bastion-${random_id.instance_id.hex}"
  labels                    = var.labels
  machine_type              = var.bastion_instance_type
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.bastion_image_id
    }
  }

  scheduling {
    preemptible = var.preemptible_instances
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform", "compute-rw"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_key)} ${var.ssh_user}"
  }

  metadata_startup_script = templatefile("./templates/bastion.sh.tftpl",
    { ssh_user        = var.ssh_user,
      ssh_private_key = tls_private_key.bastion.private_key_pem
  consul_internal_address = google_compute_address.consul-internal.address })

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.name
    network_ip = google_compute_address.bastion.address

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
}

resource "google_compute_address" "bastion" {
  provider     = google-beta
  name         = "bastion"
  subnetwork   = google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
}

resource "tls_private_key" "bastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_service_account" "bastion" {
  account_id   = "bastion"
  display_name = "Bastion Server"
}

resource "google_service_account_iam_binding" "bastion-service-account-user" {
  service_account_id = google_service_account.bastion.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${google_service_account.bastion.email}",
  ]
}
