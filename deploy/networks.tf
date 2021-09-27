resource "google_compute_network" "network" {
  name                    = "${var.deployment_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "${var.deployment_name}-subnet"
  ip_cidr_range            = var.subnet_cidr
  network                  = google_compute_network.network.id
  private_ip_google_access = true
}

resource "google_compute_address" "nat" {
  name = "${var.deployment_name}-nat"
}

resource "google_compute_router" "router" {
  name    = "${var.deployment_name}-router"
  network = google_compute_network.network.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.deployment_name}-nat"
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat.*.self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}
