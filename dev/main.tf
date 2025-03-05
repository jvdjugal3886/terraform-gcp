#-------------------------------------------------------------------------------
# API ENABLEMENT MODULE
#-------------------------------------------------------------------------------
# This module enables all required Google Cloud APIs for the specified projects.
#In this case, at the folder level we will have two seperate project IDs
#The first project ID i.e. DevOps project will be responsible for maintaing the bucket, main service account for handling terraform.
#The second project ID is where the infrastructure is being created with the service account and the bucket present in the DevOps project.
#So we need to declare seperate resources to enable the APIs for each project ID.


module "apis" {
  source = "../modules/apis"

  infra_project_id  = var.infra_project_id
  devops_project_id = var.devops_project_id
  infra_apis        = var.infra_apis
  devops_apis       = var.devops_apis

}

#-------------------------------------------------------------------------------
# VPC NETWORK MODULE
#-------------------------------------------------------------------------------
# This module provisions a Virtual Private Cloud (VPC) with subnets, NAT, and routing configurations.

module "vpc" {
  source      = "../modules/vpc"
  project_id  = var.project_id
  vpc_configs = var.vpc_configs
  env         = var.env

  depends_on = [module.apis, module.apis.enabled_apis] # Ensures APIs are enabled before VPC creation
}

#-------------------------------------------------------------------------------
# GKE CLUSTER MODULE for the Standard Cluster Creation
#-------------------------------------------------------------------------------
# This module provisions a Google Kubernetes Engine (GKE) cluster with the necessary configurations.

module "gke_standard" {
  source          = "../modules/gke_standard"
  project_id      = var.project_id
  cluster_configs = var.cluster_configs
  region          = var.region
  env             = var.env


  depends_on = [module.vpc]
}

#-------------------------------------------------------------------------------
# GKE AUTOPILOT MODULE
#-------------------------------------------------------------------------------


module "gke_autopilot" {
  source                 = "../modules/gke_autopilot"
  project_id             = var.project_id
  cluster_names          = var.cluster_names
  region                 = var.region
  network                = var.network
  subnetwork             = var.subnetwork
  maintenance_start_time = var.maintenance_start_time
  maintenance_end_time   = var.maintenance_end_time
  maintenance_recurrence = var.maintenance_recurrence
  master_cidr            = var.master_cidr
  env                    = var.env

  depends_on = [module.gke_standard, module.vpc]
}


#-------------------------------------------------------------------------------
# CLOUD SQL INSTANCE MODULE
#-------------------------------------------------------------------------------
# This module provisions a Cloud SQL instance for the application database.

module "cloud_sql" {

  depends_on = [module.vpc]

  source        = "../modules/cloud_sql"
  project_id    = var.project_id
  region        = var.region
  sql_instances = var.sql_instances

}

#-------------------------------------------------------------------------------
# CLOUD ARMOR SECURITY POLICY MODULE
#-------------------------------------------------------------------------------
# This module will provision Cloud Armor security policies for application protection.
# Set the configurations for this module as per your prpject requirements.

#-------------------------------------------------------------------------------
# GOOGLE COMPUTE ENGINE INSTANCE MODULE
#-------------------------------------------------------------------------------

module "gce" {
  source     = "../modules/gce"
  project_id = var.project_id
  instances  = var.instances
  env        = var.env

  depends_on = [module.cloud_sql] # Ensures Cloud SQL is available before GCE
}



#-------------------------------------------------------------------------------
# CLOUD RUN MODULE
#-------------------------------------------------------------------------------
# This module provisions Cloud Run services for serverless deployments.


module "cloud_run" {
  source             = "../modules/cloud_run"
  project_id         = var.project_id
  region             = var.region
  cloud_run_services = var.cloud_run_services
  env                = var.env
}


#-------------------------------------------------------------------------------
# CLOUD DNS MODULE
#-------------------------------------------------------------------------------
# This module sets up Cloud DNS for domain name resolution.


module "cloud_dns" {
  source     = "../modules/cloud_dns"
  project_id = var.project_id
  region     = var.region
  dns_zones  = var.dns_zones
  env        = var.env
}


#-------------------------------------------------------------------------------
# CLOUD CDN MODULE
#-------------------------------------------------------------------------------
# This module provisions Cloud CDN for caching and accelerating content delivery.


module "cloud_cdn" {
  source        = "../modules/cloud_cdn"
  project_id    = var.project_id
  region        = var.region
  cdn_instances = var.cdn_instances
  env           = var.env
}



#-------------------------------------------------------------------------------
# IDENTITY PLATFORM MODULE
#-------------------------------------------------------------------------------
# This module configures Identity Platform for authentication and user management.


module "identity_platform" {
  source               = "../modules/identity_platform"
  project_id           = var.project_id
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
}

#-------------------------------------------------------------------------------
