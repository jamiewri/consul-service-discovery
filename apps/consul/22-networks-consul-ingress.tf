# External LB
resource "google_compute_global_address" "consul-external" {
  provider     = google-beta
  name         = "consul-external"
  labels       = var.labels
  address_type = "EXTERNAL"
}

resource "google_compute_url_map" "consul-external" {
  name            = "consul-external"
  default_service = google_compute_backend_service.consul-external.id
}

resource "google_compute_target_http_proxy" "consul-external" {
  provider = google-beta
  project  = var.project
  name     = "consul-external"
  url_map  = google_compute_url_map.consul-external.id
}

resource "google_compute_backend_service" "consul-external" {
  provider                        = google-beta
  name                            = "consul-external"
  enable_cdn                      = false
  timeout_sec                     = 10
  connection_draining_timeout_sec = 10
  health_checks                   = [google_compute_health_check.consul-external.self_link]
  protocol                        = "HTTP"

  backend {
    group                 = google_compute_region_instance_group_manager.consul.instance_group
    balancing_mode        = "RATE"
    max_rate_per_instance = "20"
  }
}

resource "google_compute_global_forwarding_rule" "consul-external" {
  provider              = google-beta
  depends_on            = [google_compute_subnetwork.subnet]
  name                  = "consul-external"
  labels                = var.labels
  ip_address            = google_compute_global_address.consul-external.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 80
  target                = google_compute_target_http_proxy.consul-external.self_link

}

resource "google_compute_health_check" "consul-external" {
  name                = "consul-health-internal"
  check_interval_sec  = 15
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = "8500"
    request_path = "/ui/"
  }
}

# Internal LB

resource "google_compute_address" "consul-internal" {
  provider     = google-beta
  name         = "consul-internal"
  labels       = var.labels
  address_type = "INTERNAL"
  subnetwork   = google_compute_subnetwork.subnet.self_link
}

resource "google_compute_health_check" "consul-internal" {
  provider            = google-beta
  name                = "consul-internal"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = "8500"
    request_path = "/ui/"
  }
}

resource "google_compute_region_backend_service" "consul-internal" {
  name                  = "consul-internal"
  region                = var.region
  load_balancing_scheme = "INTERNAL"
  protocol              = "TCP"
  health_checks         = [google_compute_health_check.consul-internal.self_link]

  backend {
    group = google_compute_region_instance_group_manager.consul.instance_group
  }
}

resource "google_compute_forwarding_rule" "consul-internal" {
  name                  = "consul-internal"
  region                = var.region
  ip_protocol           = "TCP"
  ip_address            = google_compute_address.consul-internal.address
  load_balancing_scheme = "INTERNAL"
  network_tier          = "PREMIUM"
  allow_global_access   = false
  subnetwork            = google_compute_subnetwork.subnet.self_link

  backend_service = google_compute_region_backend_service.consul-internal.self_link
  all_ports       = true
}





