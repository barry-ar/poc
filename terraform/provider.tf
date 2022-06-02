terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.15.0"
    }
  }
}

provider "google" {
  project     = "my-project-id"
  region      = "europe-west1"
}