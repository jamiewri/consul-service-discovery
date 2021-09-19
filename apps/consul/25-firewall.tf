resource "google_compute_firewall" "security_group-ssh" {
  name    = "${var.deployment_name}-security-group-ssh"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports = [
      "22",
      "80",
      "9200",
      "9201",
      "9202"
    ]
  }

  source_ranges = [
    local.myip,
    google_compute_subnetwork.subnet.ip_cidr_range,
  ]
}

resource "google_compute_firewall" "security_group-http" {
  name    = "${var.deployment_name}-security-group-http"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports = [
      "80",
      "443",
      "8200"
    ]
  }
  source_ranges = [
    local.myip,
    google_compute_subnetwork.subnet.ip_cidr_range,
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

resource "google_compute_firewall" "security_group-vault" {
  name    = "${var.deployment_name}-security-group-vault"
  network = google_compute_network.network.id

  allow {
    protocol = "tcp"
    ports = [
      "80",
      "8200",
      "8300",
      "8301",
      "8500",
      "8600"
    ]
  }

  allow {
    protocol = "udp"
    ports = [
      "8600"
    ]
  }

  source_ranges = [
    local.myip,
    google_compute_subnetwork.subnet.ip_cidr_range,
    "130.211.0.0/22",
    "35.191.0.0/16",
    "209.85.152.0/22",
    "209.85.204.0/22",
    "10.240.0.0/14"
  ]
}
