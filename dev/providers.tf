# ------------------------------------------------------------------
# Google Cloud Provider Configuration
# This block defines the Google Cloud provider and its authentication method.
# ------------------------------------------------------------------
provider "google" {

  project = var.project_id
  region  = var.region
}

# ------------------------------------------------------------------
# Terraform Provider Requirements
# This ensures that Terraform uses a compatible version of the Google provider.
# ------------------------------------------------------------------

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.10.0"
    }

  }
}
