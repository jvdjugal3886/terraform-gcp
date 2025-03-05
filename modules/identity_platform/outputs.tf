# Output block to expose the OAuth configuration details
output "oauth_config" {

  # Description of the output variable to provide clarity on its purpose
  description = "The OAuth configuration for Google sign-in"

  # Retrieves the name of the Google Identity Platform OAuth IDP (Identity Provider) configuration
  value = google_identity_platform_oauth_idp_config.google_oauth.name

  # Marks the output as sensitive to prevent it from being displayed in plaintext in logs or CLI outputs
  sensitive = true
}
