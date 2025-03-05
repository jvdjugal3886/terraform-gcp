# main.tf

#Creates VPC networks based on the configurations provided in the var.vps_configs
resource "google_compute_network" "vpc" {
  for_each = var.vpc_configs

  name                    = "${each.value.name}-${var.env}"    # Append env to VPC name  project                 = var.project_id                     # GCP Project ID
  auto_create_subnetworks = each.value.auto_create_subnetworks #Whether to auto-create subnets
  routing_mode            = each.value.routing_mode            # Routing mode (e.g., "REGIONAL" or "GLOBAL").

  # Optional timeouts for VPC operations (create, update, delete).
  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  # Lifecycle configuration to ignore specific changes.
  lifecycle {
    ignore_changes = [] # Define a default empty list
  }
}

# Creates subnets within the VPCs based on the configurations provided in `var.vpc_configs`.
resource "google_compute_subnetwork" "subnets" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs : [
        for subnet in vpc.subnet_configs : {
          vpc_key    = vpc_key
          subnet_key = "${vpc_key}-${subnet.name}"
          subnet     = subnet
        }
      ]
    ]) : pair.subnet_key => pair
  }

  name                     = "${each.value.subnet.name}-${var.env}"            # Append env to subnet name
  ip_cidr_range            = each.value.subnet.ip_cidr_range                   # Ensure this is provided
  region                   = each.value.subnet.region                          # Region where the subnet will be created.
  network                  = google_compute_network.vpc[each.value.vpc_key].id # Associated VPC.
  project                  = var.project_id                                    # GCP project ID.
  private_ip_google_access = each.value.subnet.private_google_access           # Enable private Google access.

  # Optional secondary IP ranges for the subnet.
  dynamic "secondary_ip_range" {
    for_each = each.value.subnet.secondary_ip_ranges != null ? each.value.subnet.secondary_ip_ranges : []
    content {
      range_name    = secondary_ip_range.value.range_name    # Name of the secondary IP range.
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range # CIDR range for the secondary IP range.
    }
  }

  # Optional logging configuration for the subnet.
  dynamic "log_config" {
    for_each = each.value.subnet.log_config != null ? [each.value.subnet.log_config] : []
    content {
      aggregation_interval = log_config.value.aggregation_interval # Log aggregation interval.
      flow_sampling        = log_config.value.flow_sampling        # Flow sampling rate.
      metadata             = log_config.value.metadata             # Metadata to include in logs.
    }
  }

  # Lifecycle configuration to ignore specific changes.
  lifecycle {
    ignore_changes = [] # Define a default empty list.
  }
}

# Creates routers for the VPCs based on the configurations provided in `var.vpc_configs`.
resource "google_compute_router" "router" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs :
      vpc.router_config != null ? [{ vpc_key = vpc_key, config = vpc.router_config }] : []
    ]) : "${pair.vpc_key}-${pair.config.name}" => pair
  }

  name    = "${each.value.config.name}-${var.env}"            # Append env to router name                           # Name of the router.
  network = google_compute_network.vpc[each.value.vpc_key].id # Associated VPC.
  region  = each.value.config.region                          # Region where the router will be created.
  project = var.project_id                                    # GCP project ID.


  # Optional BGP configuration for the router.
  dynamic "bgp" {
    for_each = each.value.config.bgp != null ? [each.value.config.bgp] : []
    content {
      asn = bgp.value.asn # BGP Autonomous System Number (ASN)
    }
  }
}

# Creates NAT gateways for the VPCs based on the configurations provided in `var.vpc_configs`.
resource "google_compute_router_nat" "nat" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs :
      vpc.nat_config != null ? [{
        vpc_key     = vpc_key,
        router_name = vpc.router_config != null ? vpc.router_config.name : null,
        config      = vpc.nat_config
      }] : []
    ]) : "${pair.vpc_key}-${pair.config.name}" => pair
    if pair.router_name != null
  }

  name                               = "${each.value.config.name}-${var.env}"                                                 # Append env to NAT gateway name                                                                # Name of the NAT gateway.
  router                             = google_compute_router.router["${each.value.vpc_key}-${each.value.router_name}"].name   # Associated router.
  project                            = var.project_id                                                                         # GCP project ID.
  region                             = google_compute_router.router["${each.value.vpc_key}-${each.value.router_name}"].region # Region for the NAT gateway.
  nat_ip_allocate_option             = each.value.config.nat_ip_allocate_option                                               # NAT IP allocation option.
  source_subnetwork_ip_ranges_to_nat = each.value.config.source_subnetwork_ip_ranges_to_nat                                   # Source IP ranges to NAT.

  # Optional NAT IP addresses.
  nat_ips = each.value.config.nat_ips != null ? each.value.config.nat_ips : []


  # Optional subnetwork configurations for NAT.
  dynamic "subnetwork" {
    for_each = each.value.config.subnetworks != null ? each.value.config.subnetworks : []
    content {
      name                    = subnetwork.value.name                    # Name of the subnetwork.
      source_ip_ranges_to_nat = subnetwork.value.source_ip_ranges_to_nat # Source IP ranges to NAT for this subnetwork.
    }
  }

  # Optional logging configuration for NAT.
  dynamic "log_config" {
    for_each = each.value.config.log_config != null ? [each.value.config.log_config] : []
    content {
      enable = log_config.value.enable # Whether to enable logging.
      filter = log_config.value.filter # Log filter.
    }
  }
}

# Creates global private IP addresses for Private Service Connect configurations.
resource "google_compute_global_address" "private_ip_address" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs :
      vpc.private_service_connect_config != null ? [{ vpc_key = vpc_key, config = vpc.private_service_connect_config }] : []
    ]) : "${pair.vpc_key}-${pair.config.name}" => pair
  }

  name          = "${each.value.config.name}-${var.env}"            # Name of the private IP address.
  purpose       = each.value.config.purpose                         # Purpose of the address (e.g., "VPC_PEERING").
  address_type  = each.value.config.address_type                    # Type of address (e.g., "INTERNAL").
  prefix_length = each.value.config.prefix_length                   # Prefix length for the IP range.
  network       = google_compute_network.vpc[each.value.vpc_key].id # Associated VPC.
  project       = var.project_id                                    # GCP project ID.
}

# Creates Private Service Connect connections for the VPCs.
resource "google_service_networking_connection" "private_vpc_connection" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs :
      vpc.private_service_connect_config != null ? [{ vpc_key = vpc_key, config = vpc.private_service_connect_config }] : []
    ]) : "${pair.vpc_key}-${pair.config.name}" => pair
  }

  network                 = google_compute_network.vpc[each.value.vpc_key].id                                                          # Associated VPC.
  service                 = each.value.config.service                                                                                  # Service to connect to (e.g., "servicenetworking.googleapis.com").
  reserved_peering_ranges = [google_compute_global_address.private_ip_address["${each.value.vpc_key}-${each.value.config.name}"].name] # Reserved IP range.


  depends_on = [
    google_compute_global_address.private_ip_address
  ]
}

# Configures peering routes for Private Service Connect connections.
resource "google_compute_network_peering_routes_config" "peering_routes" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs :
      vpc.private_service_connect_config != null ? [{ vpc_key = vpc_key, config = vpc.private_service_connect_config }] : []
    ]) : "${pair.vpc_key}-${pair.config.name}" => pair
  }

  project = google_compute_network.vpc[each.value.vpc_key].project                        # GCP project ID.
  network = google_compute_network.vpc[each.value.vpc_key].name                           # Associated VPC.
  peering = google_service_networking_connection.private_vpc_connection[each.key].peering # Peering connection.

  # Export settings from the variable, with a default of true
  export_custom_routes = lookup(each.value.config, "export_custom_routes", true)

  # Import settings - we should add this to the variable definition as well
  import_custom_routes = lookup(each.value.config, "import_custom_routes", true)

  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]
}

# Creates firewall rules for the VPCs based on the configurations provided in `var.vpc_configs`.
resource "google_compute_firewall" "rules" {
  for_each = {
    for pair in flatten([
      for vpc_key, vpc in var.vpc_configs : [
        for rule in vpc.firewall_rules : {
          vpc_key = vpc_key
          rule    = rule
        }
      ]
    ]) : "${pair.vpc_key}-${pair.rule.name}" => pair
  }

  name        = "${each.value.rule.name}-${var.env}"                # Name of the firewall rule.
  network     = google_compute_network.vpc[each.value.vpc_key].name # Associated VPC.
  project     = var.project_id                                      # GCP project ID.
  description = lookup(each.value.rule, "description", null)        # Optional description.
  direction   = lookup(each.value.rule, "direction", "INGRESS")     # Direction of the rule (default: "INGRESS").
  priority    = lookup(each.value.rule, "priority", 1000)           # Priority of the rule (default: 1000).

  # Allow rules configuration.
  dynamic "allow" {
    for_each = coalesce(lookup(each.value.rule, "allow", []), [])
    content {
      protocol = allow.value.protocol               # Protocol to allow (e.g., "tcp").
      ports    = lookup(allow.value, "ports", null) # Optional ports to allow.
    }
  }

  # Deny rules configuration.
  dynamic "deny" {
    for_each = coalesce(lookup(each.value.rule, "deny", []), [])
    content {
      protocol = deny.value.protocol               # Protocol to deny (e.g., "udp").
      ports    = lookup(deny.value, "ports", null) # Optional ports to deny.
    }
  }

  source_ranges           = lookup(each.value.rule, "source_ranges", null)           # Optional source IP ranges.
  source_tags             = lookup(each.value.rule, "source_tags", null)             # Optional source tags.
  source_service_accounts = lookup(each.value.rule, "source_service_accounts", null) # Optional source service accounts.
  target_tags             = lookup(each.value.rule, "target_tags", null)             # Optional target tags.
  target_service_accounts = lookup(each.value.rule, "target_service_accounts", null) # Optional target service accounts.
}
