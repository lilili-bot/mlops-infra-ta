# Terraform GKE Setup 

This repository contains the Terraform configuration to deploy GKE clusters for staging and production environments on Google Cloud Platform.

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads.html)
- Service Account JSON Keys for Terraform


## Setup Instructions

### Local Development

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/your-repo.git
   cd your-repo
   ```
2. **Authenticate your service account
```
gcloud auth activate-service-account --key-file=path/to/your/terraform-key.json
```
3. **export envs
export GOOGLE_CREDENTIALS=$(cat path/to/your/terraform-key.json)
export TF_VAR_gcp_credentials_json="$GOOGLE_CREDENTIALS"
4. Terraform
```
terraform init -backend-config="terraform/backend_configs/staging-backend-config.hcl"
terraform plan -var-file="terraform/envs/staging.tfvars"
```
Please be careful with terraform apply, because it will deploy GKE cluster with one node.

