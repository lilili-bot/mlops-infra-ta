provider "google" {
  credentials = file("path/to/your/terraform-key.json")
  project     = "your-project-id"
  region      = "us-central1"  # Choose your preferred region
}

resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = "us-central1"    # Change to your desired region

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
