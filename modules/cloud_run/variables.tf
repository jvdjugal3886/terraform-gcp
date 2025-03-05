# Define a variable to store the project ID.
# This is the Google Cloud project where all resources will be deployed.
variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}


# Define a variable to specify the deployment region.
# This determines where the resources will be provisioned within Google Cloud.
variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

# Define a variable to configure multiple Cloud Run services.
# Each service will be deployed with its respective name, location, and container image.
variable "cloud_run_services" {
  description = "Configuration for Cloud Run services"
  type = list(object({

    # Name of the Cloud Run service
    name = string

    # Location (region) where the service will be deployed
    location = string

    # Container image for the Cloud Run service (stored in Artifact Registry or Container Registry)
    image = string
  }))
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
