# Output block to display the name of the Cloud Armor security policy
output "security_policy_name" {
  description = "The name of the Cloud Armor security policy"

  # The value being output, which references the name of the `google_compute_security_policy` resource
  value = google_compute_security_policy.cloud_armour.name
}
