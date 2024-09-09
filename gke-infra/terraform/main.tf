terraform {
  backend "gcs" {
    bucket  = "terraform_ll"
    prefix  = "terraform/state"
  }
}

provider "google" {
  credentials = var.gcp_credentials_json
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = var.region

  # Create a new custom node pool with minimal configuration
  node_pool {
    name       = "demo-pool"
    initial_node_count = 1

    node_config {
      machine_type = "e2-small"      # Lightweight machine type
      disk_size_gb = 10              # Small disk size

      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }

    management {
      auto_upgrade = false
      auto_repair  = false
    }
  }

  # Disable Cloud Logging and Monitoring (optional)
  logging_service    = "none"
  monitoring_service = "none"

  # Disable Kubernetes Dashboard and other optional features
  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = true
    }
    network_policy_config {
      disabled = true
    }
  }
}