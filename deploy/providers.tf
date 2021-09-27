terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.83.0"
    }
  }

  # Your should really think about uncommenting this
  #backend "gcs" {
  #  bucket = "devopstower-tf-state-prod"
  #  prefix = "terraform/consul-service-registry"
  #}
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Using the beta provider so we can add labels to global compute addresses
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address#labels

provider "google-beta" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
