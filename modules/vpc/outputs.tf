# outputs.tf

# Outputs the names of all created VPCs as a map, where the key is the VPC identifier and the value is the VPC name.
output "vpc_names" {
  value = { for k, v in google_compute_network.vpc : k => v.name }
}

# Outputs the IDs of all created VPCs as a map, where the key is the VPC identifier and the value is the VPC ID.
output "network_ids" {
  value = { for k, v in google_compute_network.vpc : k => v.id }
}

# Outputs the names of all created routers as a map, where the key is the router identifier and the value is the router name.
output "router_names" {
  value = { for k, v in google_compute_router.router : k => v.name }
}

# Outputs the names of all created NAT gateways as a map, where the key is the NAT identifier and the value is the NAT name.
output "nat_names" {
  value = { for k, v in google_compute_router_nat.nat : k => v.name }
}

# Outputs a list of all created subnet names.
output "subnet_names" {
  description = "List of subnet names created"
  value       = [for s in google_compute_subnetwork.subnets : s.name]
}

# Outputs the details of the Private Service Connect connection, including its configuration and status.
output "private_vpc_connection" {
  value = google_service_networking_connection.private_vpc_connection
}
