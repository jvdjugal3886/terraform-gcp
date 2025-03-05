output "standard_cluster_id" {
  value = {
    for cluster_key, cluster in google_container_cluster.standard : cluster_key => cluster.id
  }
}

output "standard_cluster_endpoint" {
  value = {
    for cluster_key, cluster in google_container_cluster.standard : cluster_key => cluster.endpoint
  }
}

output "standard_cluster_name" {
  value = {
    for cluster_key, cluster in google_container_cluster.standard : cluster_key => cluster.name
  }
}
