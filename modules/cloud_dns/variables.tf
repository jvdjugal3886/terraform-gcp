# Define a variable to store the project ID.
# This is the Google Cloud project where all resources will be deployed.
variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

# Define a variable to specify the deployment region.
# This determines where the resources will be provisioned within Google Cloud.
variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}


# Define a variable to configure multiple Cloud DNS managed zones.
# These managed zones contain DNS records for domains hosted on Google Cloud.
variable "dns_zones" {
  description = "Configuration for DNS managed zones"
  type = list(object({
    name        = string
    dns_name    = string
    description = string
  }))
}
