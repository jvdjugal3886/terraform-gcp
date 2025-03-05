# Create the subnet in the existing VPC
resource "google_compute_subnetwork" "gke_subnet" {
  for_each = var.cluster_configs

  name          = "${each.value.subnet_config.name}-${var.env}"
  ip_cidr_range = each.value.subnet_config.ip_cidr_range
  region        = each.value.subnet_config.region
  network       = each.value.network
  project       = var.project_id

  private_ip_google_access = each.value.subnet_config.private_google_access

  dynamic "secondary_ip_range" {
    for_each = each.value.subnet_config.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

# Main configuration for GKE clusters
resource "google_service_account" "gke_sa" {
  for_each = var.cluster_configs

  account_id   = "${each.value.name}-sa"
  display_name = "GKE Service Account for ${each.value.name}"
  project      = var.project_id
}

resource "google_project_iam_member" "gke_sa_permissions" {
  for_each = {
    for pair in flatten([
      for cluster_key, cluster in var.cluster_configs : [
        for permission in cluster.gke_sa_permissions : {
          cluster_key = cluster_key
          permission  = permission
        }
      ]
    ]) : "${pair.cluster_key}-${pair.permission}" => pair
  }

  project = var.project_id
  role    = each.value.permission
  member  = "serviceAccount:${google_service_account.gke_sa[each.value.cluster_key].email}"
}

resource "google_container_cluster" "standard" {
  for_each = var.cluster_configs

  name                     = "${each.value.name}-standard-${var.env}"
  location                 = each.value.zone
  project                  = var.project_id
  deletion_protection      = each.value.deletion_protection
  network                  = each.value.network
  subnetwork               = each.value.subnetwork
  remove_default_node_pool = true
  initial_node_count       = 1



  dynamic "ip_allocation_policy" {
    for_each = each.value.ip_allocation_policy != null ? [each.value.ip_allocation_policy] : []
    content {
      cluster_ipv4_cidr_block  = ip_allocation_policy.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = ip_allocation_policy.value.services_ipv4_cidr_block
    }
  }

  dynamic "release_channel" {
    for_each = each.value.release_channel != null ? [each.value.release_channel] : []
    content {
      channel = release_channel.value
    }
  }

  dynamic "vertical_pod_autoscaling" {
    for_each = each.value.vertical_pod_autoscaling_enabled != null ? [each.value.vertical_pod_autoscaling_enabled] : []
    content {
      enabled = vertical_pod_autoscaling.value
    }
  }





  dynamic "gateway_api_config" {
    for_each = each.value.gateway_api_channel != null ? [each.value.gateway_api_channel] : []
    content {
      channel = gateway_api_config.value
    }
  }


  dynamic "dns_config" {
    for_each = each.value.dns_config != null ? [each.value.dns_config] : []
    content {
      cluster_dns        = dns_config.value.cluster_dns
      cluster_dns_domain = dns_config.value.cluster_dns_domain
    }
  }

  dynamic "addons_config" {
    for_each = each.value.addons_config != null ? [each.value.addons_config] : []
    content {
      http_load_balancing {
        disabled = !addons_config.value.http_load_balancing_enabled
      }
      dns_cache_config {
        enabled = addons_config.value.dns_cache_enabled
      }
      gcs_fuse_csi_driver_config {
        enabled = addons_config.value.gcs_fuse_csi_driver_enabled
      }
      gcp_filestore_csi_driver_config {
        enabled = addons_config.value.gcp_filestore_csi_driver_enabled
      }
      config_connector_config {
        enabled = addons_config.value.config_connector_enabled
      }


    }
  }

  enable_shielded_nodes = each.value.enable_shielded_nodes
  networking_mode       = each.value.networking_mode




  dynamic "network_policy" {
    for_each = each.value.network_policy != null ? [each.value.network_policy] : []
    content {
      enabled  = network_policy.value.enabled
      provider = network_policy.value.provider
    }
  }

  dynamic "private_cluster_config" {
    for_each = each.value.private_cluster_config != null ? [each.value.private_cluster_config] : []
    content {
      enable_private_nodes    = private_cluster_config.value.enable_private_nodes
      enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
      master_ipv4_cidr_block  = lookup(private_cluster_config.value, "master_ipv4_cidr_block", "10.0.80.0/28")
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = each.value.private_cluster_config.enable_private_endpoint ? [1] : []
    content {

    }
  }

  dynamic "maintenance_policy" {
    for_each = each.value.maintenance_policy != null ? [each.value.maintenance_policy] : []
    content {
      recurring_window {
        start_time = maintenance_policy.value.start_time
        end_time   = maintenance_policy.value.end_time
        recurrence = maintenance_policy.value.recurrence
      }
    }
  }
}

resource "google_container_node_pool" "standard_nodes" {
  for_each = {
    for pair in flatten([
      for cluster_key, cluster in var.cluster_configs : [
        for node_pool in cluster.node_pools : {
          cluster_key = cluster_key
          node_pool   = node_pool
        }
      ]
    ]) : "${pair.cluster_key}-${pair.node_pool.name}" => pair
  }

  name     = "${each.value.node_pool.name}-${var.env}"
  cluster  = google_container_cluster.standard[each.value.cluster_key].name
  location = var.cluster_configs[each.value.cluster_key].zone

  node_count = each.value.node_pool.node_count

  # Node pool management configuration
  management {
    auto_repair  = each.value.node_pool.auto_repair
    auto_upgrade = each.value.node_pool.auto_upgrade
  }

  dynamic "autoscaling" {
    for_each = lookup(each.value.node_pool, "autoscaling", null) != null ? [each.value.node_pool.autoscaling] : []
    content {
      min_node_count = autoscaling.value.min_node_count
      max_node_count = autoscaling.value.max_node_count
    }
  }

  node_config {
    machine_type    = each.value.node_pool.machine_type
    disk_size_gb    = each.value.node_pool.disk_size_gb
    disk_type       = each.value.node_pool.disk_type
    service_account = google_service_account.gke_sa[each.value.cluster_key].email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
