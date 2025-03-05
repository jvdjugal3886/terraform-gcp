variable "project_id" {}
variable "region" {}
variable "cluster_names" {
  type    = list(string)
  default = ["cluster-1", "cluster-2"]
}


variable "network" {}
variable "subnetwork" {}

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

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}
