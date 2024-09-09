provider "google" {
  credentials = var.gcp_credentials_json
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = var.region

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

terraform {
  backend "gcs" {
    bucket  = "your-bucket-name"
    prefix  = "terraform/state"
  }
}
