# Output block to list the enabled APIs for the infrastructure project
output "infra_enabled_apis" {

  # Description of the output variable to clarify its purpose
  description = "List of enabled APIs for the infrastructure project"
  value       = [for api in google_project_service.infra_enabled_apis : api.service]
}

output "devops_enabled_apis" {
  description = "List of enabled APIs for the devops project"
  value       = [for api in google_project_service.devops_enabled_apis : api.service]
}
