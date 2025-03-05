# Resource block to create Google Cloud DNS Managed Zones
resource "google_dns_managed_zone" "cloud_dns" {
  # Use `for_each` to iterate over the `dns_zones` variable and create a managed zone for each entry
  for_each = { for idx, zone in var.dns_zones : idx => zone }

  # Name of the DNS managed zone, derived from the `name` attribute in the `dns_zones` variable
  name = "${each.value.name}-${var.env}" # Append env to the DNS zone name

  # DNS name of the managed zone, derived from the `dns_name` attribute in the `dns_zones` variable
  dns_name    = each.value.dns_name # Append env to the DNS name
  description = each.value.description

  project = var.project_id
}
