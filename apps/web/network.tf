data "google_compute_subnetwork" "subnet" {
  name   = "consul-service-registry-subnet"
  region = var.region
}
