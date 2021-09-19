resource "google_compute_instance" "bastion" {
  name                      = "bastion-${random_id.instance_id.hex}"
  labels                    = var.labels
  machine_type              = var.bastion_instance_type
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.bastion_image_id
    }
  }

  scheduling {
    preemptible = false
  }

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["cloud-platform", "compute-rw"]
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_key} ${var.ssh_user} \n ${var.ssh_user}:${tls_private_key.bastion.public_key_openssh} ${var.ssh_user}"
  }

  metadata_startup_script = <<SCRIPT
mkdir -p /home/${var.ssh_user}/.ssh
cat << EOF > /home/${var.ssh_user}/.ssh/id_rsa
${tls_private_key.bastion.private_key_pem}
EOF
    sudo chmod 0600 /home/${var.ssh_user}/.ssh/id_rsa
    sudo chown ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/.ssh/id_rsa
    touch /home/${var.ssh_user}/metadata-done
    echo 'export CONSUL_HTTP_ADDR=http://${google_dns_record_set.consul-internal.name}:8500' >> /etc/profile.d/hashi.sh
    echo 'alias k=kubectl' >> /etc/profile.d/hashi.sh
    chmod 0644 /etc/profile.d/hashi.sh
    chown root:root /etc/profile.d/hashi.sh
    sudo systemctl stop firewalld
  SCRIPT

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
