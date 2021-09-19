resource "google_compute_network" "network" {
  name                    = "${var.deployment_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.deployment_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.network.id
  private_ip_google_access = true
}

