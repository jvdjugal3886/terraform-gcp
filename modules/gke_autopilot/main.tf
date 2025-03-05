resource "google_container_cluster" "autopilot" {
  for_each = { for idx, cluster_name in var.cluster_names : idx => cluster_name }

  name                = "${each.value}-autopilot-${var.env}"
  location            = "us-central1"
  project             = var.project_id
  deletion_protection = true # Enable in production to prevent accidental deletion
  network             = var.network
  subnetwork          = var.subnetwork
  enable_autopilot    = true

  # --- Private Cluster Configuration ---
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true            # Private control plane endpoint
    master_ipv4_cidr_block  = var.master_cidr # e.g., "172.16.0.0/28"
  }

  # --- Security ---




  # Optional: Binary Authorization (for production)
  # binary_authorization { evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" }

  # --- Networking ---
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Enable Dataplane V2 (Cilium-based networking)
  datapath_provider = "ADVANCED_DATAPATH"

  # Optional: Restrict control plane access
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.authorized_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value
        display_name = cidr_blocks.key
      }
    }
  }

  # --- Observability ---
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus { enabled = true } # Enable for Prometheus metrics
  }

  # --- Cluster Upgrades & Maintenance ---
  release_channel {
    channel = "REGULAR" # Use "STABLE" for production-critical clusters
  }

  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }

  # --- Autopilot-Specific Features ---
  vertical_pod_autoscaling { enabled = true }

  # --- Cluster DNS (Optional) ---
  dns_config {
    cluster_dns       = "CLOUD_DNS" # Use Cloud DNS for private zones
    cluster_dns_scope = "CLUSTER_SCOPE"
  }

  # --- Resource Labels (Cost Tracking) ---
  resource_labels = {
    environment = "prod"
    team        = "devops"
  }
}
