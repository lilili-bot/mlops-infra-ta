variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "gcp_credentials_json" {
  description = "Path to the GCP credentials JSON file"
  type        = string
  default     = ""
}
