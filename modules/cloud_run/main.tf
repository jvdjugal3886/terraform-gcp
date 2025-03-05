# Resource block to create Google Cloud Run services
resource "google_cloud_run_service" "cloud_run" {

  # Use `for_each` to iterate over the `cloud_run_services` variable and create a Cloud Run service for each entry
  for_each = { for idx, service in var.cloud_run_services : idx => service }


  name = "${each.value.name}-${var.env}"

  # Location (region) where the Cloud Run service will be deployed, derived from the `location` attribute in the `cloud_run_services` variable
  location = each.value.location
  project  = var.project_id

  template {
    spec {

      # Container configuration for the Cloud Run service
      containers {
        # Docker image to deploy, derived from the `image` attribute in the `cloud_run_services` variable
        image = each.value.image
      }
    }
  }
}

# Resource block to set IAM policies for public access to the Cloud Run services
resource "google_cloud_run_service_iam_policy" "public_access" {

  # Use `for_each` to iterate over the `cloud_run_services` variable and apply IAM policies to each Cloud Run service
  for_each = { for idx, service in var.cloud_run_services : idx => service }

  # Name of the Cloud Run service, referenced from the `google_cloud_run_service.cloud_run` resource
  service = google_cloud_run_service.cloud_run[each.key].name

  # Location (region) of the Cloud Run service, referenced from the `google_cloud_run_service.cloud_run` resource
  location = google_cloud_run_service.cloud_run[each.key].location

  # IAM policy data to apply, sourced from the `data.google_iam_policy.public_iam_policy` data source
  policy_data = data.google_iam_policy.public_iam_policy.policy_data
}

# Data block to define an IAM policy for public access
data "google_iam_policy" "public_iam_policy" {


  # IAM policy binding to grant the `roles/run.invoker` role to all users

  binding {

    # Role to assign (allows invoking the Cloud Run service)
    role = "roles/run.invoker"

    # Members to grant the role to (in this case, `allUsers` for public access)
    members = ["allUsers"]
  }
}
