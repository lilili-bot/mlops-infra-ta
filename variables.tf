variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "credentials_file" {
  description = "Path to the service account key file"
  type        = string
}
