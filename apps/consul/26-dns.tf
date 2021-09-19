resource "google_dns_managed_zone" "internal-gcp" {
  name        = "internal-gcp"
  dns_name    = "internal-gcp.openinfra.io."

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.network.id
    }
  }
}

resource "google_dns_record_set" "consul" {
  name         = "consul.gcp.openinfra.io."
  managed_zone = "gcp"
  type         = "A"
  ttl          = 30
  rrdatas = [google_compute_global_address.consul-external.address]
}

resource "google_dns_record_set" "consul-internal" {
  name         = "consul.internal-gcp.openinfra.io."
  managed_zone = "internal-gcp"
  type         = "A"
  ttl          = 30
  rrdatas = [google_compute_address.consul-internal.address]
  depends_on = [google_dns_managed_zone.internal-gcp]
}
