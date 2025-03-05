# Output block to display the names of the created DNS managed zones
output "dns_zone_names" {
  description = "Names of the created DNS managed zones"

  # The value being output, which is a list of names of the DNS managed zones created by the `google_dns_managed_zone.cloud_dns` resource
  value = [for zone in google_dns_managed_zone.cloud_dns : zone.name]
}

# Output block to display the DNS names of the created DNS managed zones
output "dns_zone_dns_names" {
  description = "DNS names of the created DNS managed zones"

  # The value being output, which is a list of DNS names of the DNS managed zones created by the `google_dns_managed_zone.cloud_dns` resource
  value = [for zone in google_dns_managed_zone.cloud_dns : zone.dns_name]
}
