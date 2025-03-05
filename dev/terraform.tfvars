#-------------------------------------------------------------------------------
# PROJECT CONFIGURATION
#-------------------------------------------------------------------------------


project_id = "  "  #Here you have to mention the project ID in which the resources/infrastructure will be created.
region     = "  "  #Enter the region
network    = "  "  #Enter the network name of your choice for the VPC
subnetwork = "  "  #Enter the subnetwork name of your choice for the Subnet.


#-------------------------------------------------------------------------------
# VPC NETWORK CONFIGURATION
#-------------------------------------------------------------------------------


vpc_configs = {
  "mdk-vpc" = {
    name                    = "   "  #Enter the network name of your choice for the VPC
    auto_create_subnetworks = false
    routing_mode            = "REGIONAL"
    description             = "VPC Network with dynamic configuration"

    # Subnet configurations
     subnet_config = {
      name                  = "               " # Name of the subnet to be created
      ip_cidr_range         = "10.0.0.0/20"     # CIDR range for the subnet
      region                = "           "     # Region for the subnet
      private_google_access = true              # Enable private Google access
      secondary_ip_ranges = [
        {
          range_name    = "pods" # Secondary range for pods
          ip_cidr_range = "10.0.96.0/20"
        },
        {
          range_name    = "services" # Secondary range for services
          ip_cidr_range = "10.12.0.0/21"
        }
      ]
    }


    # Router configuration
    router_config = {
      name   = "   "  #Enter the desired router name of your choice
      region = "   "  #Enter the desired router name of your choice
    }

    # NAT configuration
    nat_config = {
      name                               = "   "  #Enter the name you wish to keep for the NAT configuration
      nat_ip_allocate_option             = "AUTO_ONLY"
      source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    }
    private_service_connect_config = {
      name                 = "   "  #Enter the name of the private service connection you wish to have
      purpose              = "VPC_PEERING"
      address_type         = "INTERNAL"
      prefix_length        = 16
      service              = "servicenetworking.googleapis.com"
      export_custom_routes = true
      import_custom_routes = true
    }

  }
}


#-------------------------------------------------------------------------------
# CLOUD ARMOR SECURITY POLICY
#-------------------------------------------------------------------------------
/*
rules = [
  {
    priority      = 1000
    action        = "allow"
    src_ip_ranges = ["192.168.1.0/24"]
    description   = "Allow internal traffic"
  },
  {
    priority      = 1100
    action        = "allow"
    src_ip_ranges = ["10.0.0.0/16"]
    description   = "Allow VPC traffic"
  },
  {
    priority      = 1200
    action        = "deny(403)"
    src_ip_ranges = ["0.0.0.0/0"]
    description   = "Deny all other traffic"
  },
  {
    priority      = 1300
    action        = "allow"
    src_ip_ranges = ["35.235.240.0/20"]
    description   = "Allow Google Cloud health checks"
  },
  {
    priority      = 1400
    action        = "deny(403)"
    src_ip_ranges = ["203.0.113.0/24"]
    description   = "Deny traffic from specific external IPs"
  },
   {
    priority    = 1500
    action      = "deny(403)"
    waf_rule    = "sqli-v33-stable"
    description = "Deny SQL Injection attempts"
  },
  {
    priority    = 1600
    action      = "deny(403)"
    waf_rule    = "xss-v33-stable"
    description = "Deny Cross-Site Scripting (XSS) attacks"
  },
  {
    priority    = 1700
    action      = "deny(403)"
    src_ip_ranges = ["0.0.0.0/0"]
    rate_limit = {
      count        = 1000
      interval_sec = 120
    }
    description = "Rate limiting for DDoS protection"
  }
]

security_policy_name = "mdk-cloud-armour"
*/

#------------------------------------------------------------------------------------------------------
# APIs to be enabled
#------------------------------------------------------------------------------------------------------


# Define the project ID for the infrastructure project.
# This project hosts core infrastructure
infra_project_id = "  "  

# Define the project ID for the DevOps project.
# This project contains resources
devops_project_id = "    "


# List of APIs to enable for the DevOps project.
# These APIs support resource management and storage operations.
devops_apis = [
  "cloudresourcemanager.googleapis.com",
  "storage.googleapis.com"
]

# List of APIs to enable for the Infrastructure project.
# These APIs are required for provisioning and managing infrastructure components.
infra_apis = [
  "container.googleapis.com",            # GKE API
  "storage.googleapis.com",              # Cloud Storage API
  "compute.googleapis.com",              # Compute Engine API
  "sqladmin.googleapis.com",             # Cloud SQL Admin API
  "servicenetworking.googleapis.com",    # Service Networking API
  "iam.googleapis.com",                  # Identity and Access Management API
  "iamcredentials.googleapis.com",       # IAM Service Account Credentials API
  "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
  "identitytoolkit.googleapis.com",      # Identity Platform API
  "cloudidentity.googleapis.com",        # Cloud Identity API
]

#-------------------------------------------------------------------------------
# CLOUD SQL INSTANCE CONFIGURATION
#-------------------------------------------------------------------------------

sql_instances = [
  { 
    name              = "   "  #Enter the name of the SQL database you wish to have
    database_version  = "POSTGRES_13"
    region            = "   "  #Enter the region in which you want the database to be created
    tier              = "db-custom-2-3840"
    availability_type = "ZONAL"
    disk_size         = 100
    disk_type         = "PD_SSD"
    enable_public_ip  = false
    enable_private_ip = true
    vpc_network       = "   "  #Enter the correct relative path of the VPC network
    maintenance_window = {
      day          = 1
      hour         = 2
      update_track = "stable"
    }
    databases = [
      {
        name = "mydb-0"
      }
    ]
    users = [
      {
        name     = "myuser-0"
        password = "mypassword-0"
      }
    ]
  }

]


#-------------------------------------------------------------------------------
# GCE INSTANCE CONFIGURATION
#-------------------------------------------------------------------------------
#Make the necessary chnages in the setting configuration as per your project requirements

instances = [
  {
    name         = "gce-instance-1"
    machine_type = "n1-standard-2"
    zone         = "us-central1-a"
    image        = "debian-cloud/debian-11"
    disk_size    = 100
    disk_type    = "pd-standard"
    network      = "default"
    public_ip    = true
    labels = {
      "environment"  = "development"
      "instance-num" = "1"
    }
  },
  {
    name         = "gce-instance-2"
    machine_type = "n1-standard-2"
    zone         = "us-central1-b"
    image        = "debian-cloud/debian-11"
    disk_size    = 100
    disk_type    = "pd-standard"
    network      = "default"
    public_ip    = true
    labels = {
      "environment"  = "development"
      "instance-num" = "2"
    }
  },
  {
    name         = "gce-instance-3"
    machine_type = "n1-standard-2"
    zone         = "us-central1-c"
    image        = "debian-cloud/debian-11"
    disk_size    = 100
    disk_type    = "pd-standard"
    network      = "default"
    public_ip    = true
    labels = {
      "environment"  = "development"
      "instance-num" = "3"
    }
  }
]


#-------------------------------------------------------------------------------
# GKE CLUSTER CONFIGURATION
#-------------------------------------------------------------------------------


cluster_configs = {
  "main-cluster" = {
    name       = "   "  #Enter the desired name of the cluster you wish to keep, this is our primary STANDARD GKE
    zone       = "   "  #Enter the region/zone in which you want the cluster to be configured
    network    = "   "  # This VPC name should be the same as the one you set in the VPC network configuration
    subnetwork = "   "  # This Subnet name should be the same as the one you set in the VPC network configuration

    deletion_protection = false
    gke_sa_permissions  = []  #Here you can add the specific roles you want to provide to the service account that has been created by the GKE module.

    # Define the custom subnet configuration
   

    ip_allocation_policy = {
      cluster_secondary_range_name  = "pods"     # Reference to the secondary range for pods
      services_secondary_range_name = "services" # Reference to the secondary range for services
    }

    # Add management configuration at the cluster level
    management = {
      auto_repair  = true
      auto_upgrade = true
    }

    # Node pool configuration
    node_pools = [
      {
        name                   = "default-pool"
        node_count             = 1
        min_node_count         = 1
        max_node_count         = 2
        machine_type           = "n1-standard-1"
        disk_size_gb           = 200
        disk_type              = "pd-standard"
        auto_repair            = true
        auto_upgrade           = true
        workload_metadata_mode = "GKE_METADATA"
        secure_boot            = true
        integrity_monitoring   = true
      }
    ]

    # Cluster feature configurations
    release_channel                  = "REGULAR"
    vertical_pod_autoscaling_enabled = true
    cost_management_enabled          = true
    gateway_api_channel              = "CHANNEL_STANDARD"
    enable_shielded_nodes            = true

    # Networking configuration
    networking_mode = "VPC_NATIVE"
    network_policy = {
      enabled  = true
      provider = "CALICO"
    }

    # Private cluster configuration
    private_cluster_config = {
      enable_private_nodes    = true
      enable_private_endpoint = true
      master_ipv4_cidr_block  = "10.0.0.0/20"
    }

    # Master authorized networks configuration
    master_authorized_networks_config = {
      cidr_blocks = [
        {
          cidr_block   = "10.0.0.0/20"
          display_name = "VPC Subnet"
        }
      ]
    }

    # DNS configuration
    dns_config = {
      cluster_dns        = "PLATFORM_DEFAULT"
      cluster_dns_domain = ""
    }

    # Addon configuration
    addons_config = {
      http_load_balancing_enabled      = true
      dns_cache_enabled                = true
      gcs_fuse_csi_driver_enabled      = false
      gcp_filestore_csi_driver_enabled = false
      config_connector_enabled         = false
    }

    # Maintenance window configuration
    maintenance_policy = {
      start_time = "2024-01-01T10:00:00Z"
      end_time   = "2024-01-01T18:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }
}


maintenance_start_time = "2025-02-22T02:00:00Z"
maintenance_end_time   = "2025-02-22T06:00:00Z"
maintenance_recurrence = "FREQ=WEEKLY;BYDAY=SA"



#GOOGLE IDENTITY PROVIDER ACCESS
#-------------------------------------------------------------------------------
# Google Identity Provider Access
# Authentication configuration for Google Identity
#-------------------------------------------------------------------------------


google_client_id     = "    "  #Enter your email ID here
google_client_secret = "    "  #Enter your password here



#-------------------------------------------------------------------------------
# CDN Configuration
# Defines Cloud CDN instances and their configurations
#-------------------------------------------------------------------------------
#Change the desired settings configurations as per your projhect requirements

cdn_instances = [
  {
    name               = "cdn-0"
    region             = "us-central1"
    bucket_name        = "cdn-backend-bucket-0"
    versioning_enabled = true
    lifecycle_rules = [
      {
        action_type = "Delete"
        age_days    = 30
      }
    ]
    cors = [
      {
        origins          = ["https://example.com"]
        methods          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        response_headers = ["*"]
        max_age_seconds  = 3600
      }
    ]
    cache_policy = {
      cache_mode  = "CACHE_ALL_STATIC"
      default_ttl = 3600
      max_ttl     = 86400
    }


  },
  {
    name               = "cdn-1"
    region             = "us-central1"
    bucket_name        = "cdn-backend-bucket-1"
    versioning_enabled = true
    lifecycle_rules = [
      {
        action_type = "Delete"
        age_days    = 30
      }
    ]
    cors = [
      {
        origins          = ["https://example.com"]
        methods          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        response_headers = ["*"]
        max_age_seconds  = 3600
      }
    ]
    cache_policy = {
      cache_mode  = "CACHE_ALL_STATIC"
      default_ttl = 3600
      max_ttl     = 86400
    }


  },
  {
    name               = "cdn-2"
    region             = "us-central1"
    bucket_name        = "cdn-backend-bucket-2"
    versioning_enabled = true
    lifecycle_rules = [
      {
        action_type = "Delete"
        age_days    = 30
      }
    ]
    cors = [
      {
        origins          = ["https://example.com"]
        methods          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
        response_headers = ["*"]
        max_age_seconds  = 3600
      }
    ]
    cache_policy = {
      cache_mode  = "CACHE_ALL_STATIC"
      default_ttl = 3600
      max_ttl     = 86400
    }


  }

]


#-------------------------------------------------------------------------------
# DNS Configuration
# Defines Cloud DNS zones and their settings
#-------------------------------------------------------------------------------


dns_zones = [
  {
    name        = "cloud-dns-zone-0"
    dns_name    = "example0.com."
    description = "Cloud DNS Zone 0"
  },

  {
    name        = "cloud-dns-zone-2"
    dns_name    = "example2.com."
    description = "Cloud DNS Zone 2"
  }
]


#-------------------------------------------------------------------------------
# Cloud Run Services
# Defines Cloud Run service configurations
#-------------------------------------------------------------------------------


cloud_run_services = [
  {
    name     = "cloud-run-service-0"
    location = "us-central1"
    image    = "gcr.io/google-samples/hello-app:1.0"
  },
  {
    name     = "cloud-run-service-1"
    location = "us-central1"
    image    = "gcr.io/google-samples/hello-app:1.0"
  },
  {
    name     = "cloud-run-service-2"
    location = "us-central1"
    image    = "gcr.io/google-samples/hello-app:1.0"
  },
  {
    name     = "cloud-run-service-3"
    location = "us-central1"
    image    = "gcr.io/google-samples/hello-app:1.0"
  }
]
#-------------------------------------------------------------------------------
master_cidr = "172.16.0.0/28"

authorized_cidr_blocks = {
  "office" = "203.0.113.0/24"
  "vpn"    = "198.51.100.0/24"
}


env = "dev"

