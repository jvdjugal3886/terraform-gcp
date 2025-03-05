# Define a variable to store the project ID.
# This is the Google Cloud project where all resources will be deployed.
variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}

# Define a variable to store the region.
# This specifies where the resources will be deployed within Google Cloud.
variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}

# Define a variable to configure multiple CDN instances.
# Each instance includes storage, security, caching, and monitoring settings.
variable "cdn_instances" {
  description = "List of CDN instances configuration"
  type = list(object({

    # Name of the CDN instance
    name = string

    # The region where the CDN instance will be deployed
    region = string

    # Name of the associated Cloud Storage bucket
    bucket_name = string

    # Flag to enable or disable versioning for the storage bucket
    versioning_enabled = bool

    # Lifecycle rules for the storage bucket (e.g., auto-deletion of old files)
    lifecycle_rules = list(object({
      action_type = string # Action to be taken (e.g., "Delete")
      age_days    = number # Number of days before applying the action
    }))

    # CORS (Cross-Origin Resource Sharing) configuration for the CDN
    cors = list(object({
      origins          = list(string) # Allowed origins (domains)
      methods          = list(string) # Allowed HTTP methods (e.g., GET, POST)
      response_headers = list(string) # Allowed response headers
      max_age_seconds  = number       # How long the response can be cached by the browser
    }))

    # Cache policy configuration for the CDN
    cache_policy = object({
      cache_mode  = string # Caching mode (e.g., "CACHE_ALL_STATIC")
      default_ttl = number # Default time-to-live (TTL) in seconds
      max_ttl     = number # Maximum TTL in seconds
    })




    # Monitoring configuration for setting up alerts

  }))
}
