# Output block to display the names of the created Cloud Run services
output "cloud_run_service_names" {
  description = "Names of the created Cloud Run services"

  # The value being output, which is a list of names of the Cloud Run services created by the `google_cloud_run_service.cloud_run` resource
  value = [for service in google_cloud_run_service.cloud_run : service.name]
}

# Output block to display the locations of the created Cloud Run services
output "cloud_run_service_locations" {
  description = "Locations of the created Cloud Run services"

  # The value being output, which is a list of locations of the Cloud Run services created by the `google_cloud_run_service.cloud_run` resource
  value = [for service in google_cloud_run_service.cloud_run : service.location]
}
