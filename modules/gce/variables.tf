# Variable to store the Google Cloud project ID where resources will be deployed
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# Variable to define the list of compute instance configurations
variable "instances" {
  description = "List of instance configurations"
  type = list(object({

    # Name of the compute instance
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
variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}

