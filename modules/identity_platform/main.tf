# Defines an OAuth identity provider configuration for Google sign-in in Google Identity Platform
resource "google_identity_platform_oauth_idp_config" "google_oauth" {

  # Specifies the Google Cloud project where this configuration will be applied
  project = var.project_id

  # Display name for the identity provider in the authentication UI
  display_name = "Google"

  # Unique identifier for the OAuth identity provider configuration
  name = "oidc.google"

  # Client ID for Google OAuth authentication, stored as a variable
  client_id = var.google_client_id

  # Client Secret for Google OAuth authentication, stored as a variable (password)
  client_secret = var.google_client_secret

  # Enables the identity provider for authentication
  enabled = true

  # The issuer URL for Google's OpenID Connect (OIDC) authentication
  issuer = "https://accounts.google.com"
}
