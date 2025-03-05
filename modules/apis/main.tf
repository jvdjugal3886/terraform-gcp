################################################################################
# ENABLE REQUIRED APIS FOR INFRA PROJECT
################################################################################
resource "google_project_service" "infra_enabled_apis" {
  for_each = toset(var.infra_apis)

  project = var.infra_project_id
  service = each.value

  disable_on_destroy         = true
  disable_dependent_services = true
}

################################################################################
# ENABLE REQUIRED APIS FOR DEVOPS PROJECT
################################################################################
resource "google_project_service" "devops_enabled_apis" {
  for_each = toset(var.devops_apis)

  project = var.devops_project_id
  service = each.value

  disable_on_destroy         = true
  disable_dependent_services = true
}
