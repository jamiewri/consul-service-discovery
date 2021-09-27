resource "google_compute_firewall" "ssh" {
  name        = "${var.deployment_name}-ssh"
  network     = google_compute_network.network.id
  description = "Allow SSH access from my IP, and internal subnet"

  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }

  source_ranges = [
    local.myip,
    google_compute_subnetwork.subnet.ip_cidr_range,
  ]
}

resource "google_compute_firewall" "http" {
  name        = "${var.deployment_name}-http"
  network     = google_compute_network.network.id
  description = "Allow HTTP/S access from my IP, local subnet and LB health check subnets"

  allow {
    protocol = "tcp"
    ports = [
      "80",
      "443",
    ]
  }
  source_ranges = [
    local.myip,
    google_compute_subnetwork.subnet.ip_cidr_range,
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

resource "google_compute_firewall" "consul" {
  name        = "${var.deployment_name}-consul"
  network     = google_compute_network.network.id
  description = "Allow Consul access from local subnet and LB health check subnets"

  allow {
    protocol = "tcp"
    ports = [
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
    google_compute_subnetwork.subnet.ip_cidr_range,
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
}

# We are running a publicaly accessable Consul server with ACLs disabled. 
# This resource restricts its access to only the IP address that ran this Terraform.
# Remove at your own risk.
resource "google_compute_security_policy" "global-whitelist" {
  name        = "whitelist"
  description = "Restricting access to Consul servers from only IP address that ran this Terraform"

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = [local.myip]
      }
    }
    description = "Allow access from IPs in ${local.myip}"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny all rule"
  }
}
