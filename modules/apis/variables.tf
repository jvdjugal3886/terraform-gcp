# Define a variable to store the Project ID for the infrastructure project.
# This is the project where the core infrastructure components
variable "infra_project_id" {
  description = "Project ID for infrastructure"
  type        = string
}

# Define a variable to store the Project ID for the DevOps project.
variable "devops_project_id" {
  description = "Project ID for devops"
  type        = string
}

# Define a list of APIs that need to be enabled for the infrastructure project.
# These APIs are necessary for provisioning resources
variable "infra_apis" {
  description = "List of APIs to enable for the infrastructure project"
  type        = list(string)
}

# Define a list of APIs that need to be enabled for the DevOps project.
# These APIs include services required for DevOps operations.
variable "devops_apis" {
  description = "List of APIs to enable for the devops project"
  type        = list(string)
}
