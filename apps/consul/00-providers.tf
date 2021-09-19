terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.51.0"
    }
  }
  backend "gcs" {
    bucket      = "devopstower-tf-state-prod"
    prefix      = "terraform/consul-service-registry"
    credentials = "~/.credentials/devopstower-eeae7b08b5d6.json"
  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = file("~/.credentials/devopstower-eeae7b08b5d6.json")
}

provider "google-beta" {
  project     = var.project
  region      = var.region
  zone        = var.zone
  credentials = file("~/.credentials/devopstower-eeae7b08b5d6.json")
}
