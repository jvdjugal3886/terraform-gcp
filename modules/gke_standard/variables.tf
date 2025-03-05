variable "project_id" {}
variable "region" {}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}
variable "cluster_configs" {
  description = "Map of cluster configurations containing all settings for GKE clusters"
  type = map(object({
    # Required fields
    name               = string
    zone               = string
    network            = string
    subnetwork         = string
    gke_sa_permissions = optional(list(string), [])

    subnet_config = object({
      name                  = string
      ip_cidr_range         = string
      region                = string
      private_google_access = bool
      secondary_ip_ranges = list(object({
        range_name    = string
        ip_cidr_range = string
      }))
    })
    deletion_protection = optional(bool, false)

    ip_allocation_policy = optional(object({
      cluster_ipv4_cidr_block  = optional(string)
      services_ipv4_cidr_block = optional(string)
    }))

    # Add management configuration
    management = optional(object({
      auto_repair  = optional(bool, true)
      auto_upgrade = optional(bool, true)
    }))


    # Optional node pool configurations with defaults
    node_pools = optional(list(object({
      name           = string
      node_count     = optional(number, 1)
      min_node_count = optional(number, 1)
      max_node_count = optional(number, 2)
      machine_type   = optional(string, "n1-standard-1")
      disk_size_gb   = optional(number, 200)
      disk_type      = optional(string, "pd-standard")
      auto_repair    = optional(bool, true)
      auto_upgrade   = optional(bool, true)
      # New autoscaling object (Fix)
      autoscaling = optional(object({
        min_node_count = optional(number, 1)
        max_node_count = optional(number, 2)
      }))
      workload_metadata_mode = optional(string, "GKE_METADATA")
      secure_boot            = optional(bool, true)

      integrity_monitoring = optional(bool, true)

      # Additional optional node configurations
      labels      = optional(map(string))
      tags        = optional(list(string))
      preemptible = optional(bool, false)
      spot        = optional(bool, false)
    })), [])

    # Optional cluster features with defaults
    release_channel                  = optional(string, "REGULAR")
    vertical_pod_autoscaling_enabled = optional(bool, true)
    cost_management_enabled          = optional(bool, true)
    gateway_api_channel              = optional(string, "CHANNEL_STANDARD")
    enable_shielded_nodes            = optional(bool, true)

    # Optional network configuration with defaults
    networking_mode = optional(string, "VPC_NATIVE")
    network_policy = optional(object({
      enabled  = optional(bool, true)
      provider = optional(string, "CALICO")
    }))

    # Optional private cluster settings
    private_cluster_config = optional(object({
      enable_private_nodes    = optional(bool, true)
      enable_private_endpoint = optional(bool, false)


    }))

    master_authorized_networks_config = optional(object({
      cidr_blocks = optional(list(object({
        cidr_block   = string
        display_name = optional(string, "Allowed Network")
      })), [])
    }))

    # Optional DNS settings
    dns_config = optional(object({
      cluster_dns        = optional(string, "PLATFORM_DEFAULT")
      cluster_dns_domain = optional(string, "")
    }))

    # Optional addon configurations
    addons_config = optional(object({
      http_load_balancing_enabled      = optional(bool, true)
      dns_cache_enabled                = optional(bool, true)
      gcs_fuse_csi_driver_enabled      = optional(bool, false)
      gcp_filestore_csi_driver_enabled = optional(bool, false)
      config_connector_enabled         = optional(bool, false)
    }))

    # Optional maintenance window
    maintenance_policy = optional(object({
      start_time = optional(string, "2024-01-01T10:00:00Z")
      end_time   = optional(string, "2024-01-01T18:00:00Z")
      recurrence = optional(string, "FREQ=WEEKLY;BYDAY=SA,SU")
    }))

    # Optional additional cluster configurations
    description        = optional(string)
    resource_labels    = optional(map(string))
    min_master_version = optional(string)
    enable_autopilot   = optional(bool, false)

    # Optional security configurations
    security_config = optional(object({
      enable_workload_identity = optional(bool, true)
      workload_pool            = optional(string)
      security_posture_config = optional(object({
        mode = optional(string, "BASIC")
      }))
      database_encryption = optional(object({
        state    = optional(string, "DECRYPTED")
        key_name = optional(string)
      }))
    }))

    # Optional monitoring and logging configurations


    # Optional binary authorization
    binary_authorization = optional(object({
      evaluation_mode = optional(string, "DISABLED")
    }))

  }))

  default = {}





  validation {
    condition = alltrue([
      for k, v in var.cluster_configs :
      contains(["VPC_NATIVE", "ROUTES"], coalesce(v.networking_mode, "VPC_NATIVE"))
    ])
    error_message = "Networking mode must be either VPC_NATIVE or ROUTES."
  }
}
