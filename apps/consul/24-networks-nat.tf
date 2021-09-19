resource "google_compute_address" "vault-nat" {
  project = var.project
  name    = "vault-nat-external"
  region  = var.region
}

resource "google_compute_router" "vault-router" {
  name    = "vault-router"
  project = var.project
  region  = var.region
  network = google_compute_network.network.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "vault-nat" {
  name    = "vault-nat-1"
  project = var.project
  router  = google_compute_router.vault-router.name
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.vault-nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}
