variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "The region where Cloud SQL will be deployed"
}
variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "sql_instances" {
  description = "Configuration for SQL instances"
  type = list(object({
    name              = string
    database_version  = string
    region            = string
    tier              = string
    availability_type = string
    disk_size         = number
    disk_type         = string
    enable_public_ip  = bool
    enable_private_ip = bool
    vpc_network       = string
    maintenance_window = object({
      day          = number
      hour         = number
      update_track = string
    })
    databases = list(object({
      name = string
    }))
    users = list(object({
      name     = string
      password = string
    }))
  }))
}



