# Output block to display the names of all created compute instances
output "instance_names" {
  description = "Names of the created instances"
  value       = [for instance in google_compute_instance.default : instance.name]
}

# Output block to display the public IP addresses of the created compute instances
output "instance_ips" {
  description = "Public IP addresses of the instances"
  value = [for instance in google_compute_instance.default :
  try(instance.network_interface[0].access_config[0].nat_ip, null)]
}

# Output block to provide detailed information about each created instance
output "instance_details" {
  description = "Details of created instances"
  value = {
    for name, instance in google_compute_instance.default : name => {
      name        = instance.name
      internal_ip = instance.network_interface[0].network_ip
      external_ip = try(instance.network_interface[0].access_config[0].nat_ip, null)
      zone        = instance.zone
    }
  }
}
