# variables.tf

#The gcp project id where the resources will be created and its associated components
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

# A map of vpc configurations where each key represents a unique VPC, 
variable "vpc_configs" {
  description = "Map of VPC configurations with all related components"
  type = map(object({
    name = string

    # Whether to automatically create subnets in the VPC. If false, subnets must be defined manually.
    auto_create_subnetworks = bool

    # The routing mode for the VPC. Can be "REGIONAL" or "GLOBAL".
    routing_mode = string

    # Optional timeouts for VPC operations (create, update, delete).
    timeouts = optional(object({
      create = optional(string)
      update = optional(string)
      delete = optional(string)
    }))

    # A list of attributes to ignore during lifecycle changes (e.g., updates).
    lifecycle_ignore_changes = optional(list(string), [])

    # A list of subnet configurations within this VPC.
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


    # Router configuration for this VPC
    router_config = optional(object({
      name   = string # The name of the router.
      region = string # The region where the router will be created.
      bgp = optional(object({
        asn = number # The BGP Autonomous System Number (ASN) for the router.
      }))
    }))

    # NAT configuration for this VPC
    nat_config = optional(object({
      name                               = string                 # The name of the NAT gateway.
      nat_ip_allocate_option             = string                 # The IP allocation option for NAT (e.g., "MANUAL_ONLY").
      source_subnetwork_ip_ranges_to_nat = string                 # The source IP ranges to NAT (e.g., "ALL_SUBNETWORKS_ALL_IP_RANGES").
      nat_ips                            = optional(list(string)) # Optional list of NAT IP addresses.
      subnetworks = optional(list(object({
        name                    = string       # The name of the subnetwork.
        source_ip_ranges_to_nat = list(string) # The source IP ranges to NAT for this subnetwork.
      })))
      log_config = optional(object({
        enable = bool   # Whether to enable logging for NAT.
        filter = string # The filter for NAT logs.
      }))
    }))

    # Private service connect configuration for this VPC
    private_service_connect_config = optional(object({
      name                 = string               # The name of the Private Service Connect configuration.
      purpose              = string               # The purpose of the Private Service Connect (e.g., "VPC_PEERING").
      address_type         = string               # The type of IP address (e.g., "INTERNAL").
      prefix_length        = number               # The prefix length for the IP range.
      service              = string               # The service to connect to (e.g., "servicenetworking.googleapis.com").
      export_custom_routes = optional(bool, true) # Whether to export custom routes.
      import_custom_routes = optional(bool, true) # Whether to import custom routes.
    }))

    # Firewall rules for this VPC
    firewall_rules = optional(list(object({
      name        = string           # The name of the firewall rule.
      description = optional(string) # A description of the firewall rule.
      direction   = optional(string) # The direction of the rule (e.g., "INGRESS" or "EGRESS").
      priority    = optional(number) # The priority of the rule (lower numbers have higher priority).
      allow = optional(list(object({
        protocol = string                 # The protocol to allow (e.g., "tcp").
        ports    = optional(list(string)) # Optional list of ports to allow.
      })))
      deny = optional(list(object({
        protocol = string                 # The protocol to deny (e.g., "udp").
        ports    = optional(list(string)) # Optional list of ports to deny.
      })))
      source_ranges           = optional(list(string)) # Optional list of source IP ranges.
      source_tags             = optional(list(string)) # Optional list of source tags.
      source_service_accounts = optional(list(string)) # Optional list of source service accounts.
      target_tags             = optional(list(string)) # Optional list of target tags.
      target_service_accounts = optional(list(string)) # Optional list of target service accounts.
    })), [])
  }))
}

variable "env" {
  description = "The environment (e.g., dev, prod)"
  type        = string

}
