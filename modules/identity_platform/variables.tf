# variables.tf

# The GCP project ID where the resources will be deployed.
# This is a required variable and must be provided when applying the Terraform configuration.
variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}


# The Google OAuth Client ID used for authentication and authorization.
# This is typically required for applications integrating with Google APIs or services.
variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
}

# The Google OAuth Client Secret used for authentication and authorization.
# This is a sensitive value and should be handled securely (e.g., using Terraform's sensitive flag).
variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
}
