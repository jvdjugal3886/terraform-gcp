output "autopilot_cluster_ids" {
  value = { for k, v in google_container_cluster.autopilot : k => v.id }
}

output "autopilot_cluster_endpoints" {
  value = { for k, v in google_container_cluster.autopilot : k => v.endpoint }
}

output "autopilot_cluster_names" {
  value = { for k, v in google_container_cluster.autopilot : k => v.name }
}
