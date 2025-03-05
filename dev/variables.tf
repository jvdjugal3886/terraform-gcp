#-------------------------------------------------------------------------------
# PROJECT CONFIGURATION
#-------------------------------------------------------------------------------
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}
variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "network" {
  default = "mdk-vpc"
}

variable "subnetwork" {
  default = "mdk-vpc-subnet1"
}



#-------------------------------------------------------------------------------
# VPC NETWORK CONFIGURATION
#-------------------------------------------------------------------------------


variable "vpc_configs" {
  description = "Map of VPC configurations with all related components"
  type = map(object({
    name                    = string
    auto_create_subnetworks = bool
    routing_mode            = string
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
    lifecycle_ignore_changes = optional(list(string), [])

    subnet_configs = optional(
      list(object({
        name                  = string
        ip_cidr_range         = string
        region                = string
        private_google_access = bool
        secondary_ip_ranges = optional(list(object({
          range_name    = string
          ip_cidr_range = string
        })))
        log_config = optional(object({
          aggregation_interval = optional(string)
          flow_sampling        = optional(number)
          metadata             = optional(string)
        }))
        lifecycle_ignore_changes = optional(list(string))
      })),
      [] // default value as an empty list if not provided
    )

    router_config = optional(object({
      name   = string
      region = string
      bgp = optional(object({
        asn = number
      }))
    }))

    nat_config = optional(object({
      name                               = string
      nat_ip_allocate_option             = string
      source_subnetwork_ip_ranges_to_nat = string
      nat_ips                            = optional(list(string))
      subnetworks = optional(list(object({
        name                    = string
        source_ip_ranges_to_nat = list(string)
      })))
      log_config = optional(object({
        enable = bool
        filter = string
      }))
    }))

    private_service_connect_config = optional(object({
      name                 = string
      purpose              = string
      address_type         = string
      prefix_length        = number
      service              = string
      export_custom_routes = optional(bool, true) # Existing setting
      import_custom_routes = optional(bool, true) # New setting
    }))
    firewall_rules = optional(list(object({
      name        = string
      description = optional(string)
      direction   = optional(string)
      priority    = optional(number)
      allow = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })))
      deny = optional(list(object({
        protocol = string
        ports    = optional(list(string))
      })))
      source_ranges           = optional(list(string))
      source_tags             = optional(list(string))
      source_service_accounts = optional(list(string))
      target_tags             = optional(list(string))
      target_service_accounts = optional(list(string))
    })), [])
  }))
}

#-------------------------------------------------------------------------------
# GKE CLUSTER CONFIGURATION
#-------------------------------------------------------------------------------


variable "cluster_configs" {
  description = "Map of cluster configurations containing all settings for GKE clusters"
  type = map(object({
    # Required fields
    name                = string
    zone                = string
    network             = string
    subnetwork          = string
    gke_sa_permissions  = optional(list(string), [])
    deletion_protection = optional(bool, false)

    subnet_config = object({
      name                  = string
      ip_cidr_range         = optional(string)
      region                = string
      private_google_access = bool
      secondary_ip_ranges = list(object({
        range_name    = string
        ip_cidr_range = string
      }))
    })

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
      integrity_monitoring   = optional(bool, true)

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



    # Optional binary authorization
    binary_authorization = optional(object({
      evaluation_mode = optional(string, "DISABLED")
    }))

  }))

  default = {}

  validation {
    condition = alltrue([
      for k, v in var.cluster_configs :
      contains(["UNSPECIFIED", "RAPID", "REGULAR", "STABLE"], coalesce(v.release_channel, "REGULAR"))
    ])
    error_message = "Release channel must be one of: UNSPECIFIED, RAPID, REGULAR, STABLE."
  }



  validation {
    condition = alltrue([
      for k, v in var.cluster_configs :
      contains(["VPC_NATIVE", "ROUTES"], coalesce(v.networking_mode, "VPC_NATIVE"))
    ])
    error_message = "Networking mode must be either VPC_NATIVE or ROUTES."
  }
}



#------------------------------------------------------------------------------------------------------
# APIs to be enabled
#------------------------------------------------------------------------------------------------------


variable "infra_project_id" {
  description = "Project ID for infrastructure"
  type        = string
}

variable "devops_project_id" {
  description = "Project ID for devops"
  type        = string
}

variable "infra_apis" {
  description = "List of APIs to enable for the infrastructure project"
  type        = list(string)
}

variable "devops_apis" {
  description = "List of APIs to enable for the devops project"
  type        = list(string)
}


#-------------------------------------------------------------------------------
# CLOUD ARMOR SECURITY POLICY
#-------------------------------------------------------------------------------
/*
variable "rules" {
  description = "List of security rules for Cloud Armor"
  type = list(object({
    priority      = number
    action        = string
    src_ip_ranges = list(string)
    description   = string
  }))
}

variable "security_policy_name" {
  description = "Name of the Cloud Armor security policy"
  type        = string
}
*/

#-------------------------------------------------------------------------------
# GCE INSTANCE CONFIGURATION
#-------------------------------------------------------------------------------


variable "instances" {
  description = "List of instance configurations"
  type = list(object({
    name         = string
    machine_type = string
    zone         = string
    image        = string
    disk_size    = number
    disk_type    = string
    network      = string
    public_ip    = bool
    labels       = map(string)
  }))
  default = []
}


#-------------------------------------------------------------------------------
# GKE AUTOPILOT
#-------------------------------------------------------------------------------


variable "maintenance_start_time" {
  description = "Start time of the maintenance window"
  type        = string
}
variable "maintenance_end_time" {
  description = "End time of the maintenance window"
  type        = string
}
variable "maintenance_recurrence" {
  description = "Recurrence schedule for maintenance"
  type        = string
}

variable "cluster_names" {
  type    = list(string)
  default = ["cluster-1", "cluster-2"]
}

# CIDR block for the GKE control plane
variable "master_cidr" {
  description = "CIDR block for the GKE control plane (e.g., '172.16.0.0/28')"
  type        = string
  default     = "172.16.0.0/28"
}

# List of authorized CIDR blocks for accessing the GKE control plane
variable "authorized_cidr_blocks" {
  description = "Map of CIDR blocks authorized to access the GKE control plane"
  type        = map(string)
  default = {
    "office" = "203.0.113.0/24"
    "vpn"    = "198.51.100.0/24"
  }
}

#-------------------------------------------------------------------------------
# IDENTITY PLATFORM CONFIGURATION
#-------------------------------------------------------------------------------


variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
}


#-------------------------------------------------------------------------------
# CDN Configuration
# Defines Cloud CDN instances and their configurations
#-------------------------------------------------------------------------------


variable "cdn_instances" {
  description = "List of CDN instances configuration"
  type = list(object({

    # Name of the CDN instance
    name = string

    # The region where the CDN instance will be deployed
    region = string

    # Name of the associated Cloud Storage bucket
    bucket_name = string

    # Flag to enable or disable versioning for the storage bucket
    versioning_enabled = bool

    # Lifecycle rules for the storage bucket (e.g., auto-deletion of old files)
    lifecycle_rules = list(object({
      action_type = string # Action to be taken (e.g., "Delete")
      age_days    = number # Number of days before applying the action
    }))

    # CORS (Cross-Origin Resource Sharing) configuration for the CDN
    cors = list(object({
      origins          = list(string) # Allowed origins (domains)
      methods          = list(string) # Allowed HTTP methods (e.g., GET, POST)
      response_headers = list(string) # Allowed response headers
      max_age_seconds  = number       # How long the response can be cached by the browser
    }))

    # Cache policy configuration for the CDN
    cache_policy = object({
      cache_mode  = string # Caching mode (e.g., "CACHE_ALL_STATIC")
      default_ttl = number # Default time-to-live (TTL) in seconds
      max_ttl     = number # Maximum TTL in seconds
    })



    # Monitoring configuration for setting up alerts

  }))
}

# Define a variable to configure multiple Cloud DNS managed zones.
# These managed zones contain DNS records for domains hosted on Google Cloud.
variable "dns_zones" {
  description = "Configuration for DNS managed zones"
  type = list(object({
    name        = string
    dns_name    = string
    description = string
  }))
}


#-------------------------------------------------------------------------------
# DNS Configuration
# Defines Cloud DNS zones and their settings
#-------------------------------------------------------------------------------
# Define a variable to configure multiple Cloud Run services.
# Each service will be deployed with its respective name, location, and container image.
variable "cloud_run_services" {
  description = "Configuration for Cloud Run services"
  type = list(object({

    # Name of the Cloud Run service
    name = string

    # Location (region) where the service will be deployed
    location = string

    # Container image for the Cloud Run service (stored in Artifact Registry or Container Registry)
    image = string
  }))
}


#-------------------------------------------------------------------------------
# CLOUD SQL INSTANCE CONFIGURATION
#-------------------------------------------------------------------------------


variable "sql_instances" {
  description = "Configuration for SQL instances"
  type = list(object({
    name              = string
    database_version  = optional(string, "POSTGRES_13")
    region            = optional(string)
    tier              = optional(string, "db-f1-micro")
    availability_type = optional(string, "ZONAL")
    disk_size         = optional(number, 10)
    disk_type         = optional(string, "PD_SSD")
    enable_public_ip  = optional(bool, false)
    enable_private_ip = optional(bool, true)
    vpc_network       = optional(string)
    maintenance_window = optional(object({
      day          = optional(number)
      hour         = optional(number)
      update_track = optional(string, "stable")
    }))
    databases = optional(list(object({
      name = string
    })), [])
    users = optional(list(object({
      name     = string
      password = string
    })), [])
  }))
  default = []
}


variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}
