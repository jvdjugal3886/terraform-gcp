/*
#Resource block to create a Google Cloud Armor security policy.
#This resource defines a security policy with rules to filter incoming traffic based on IP ranges.
resource "google_compute_security_policy" "cloud_armour" {
  name = var.security_policy_name
# Dynamic block to create multiple rules based on the `rules` variable
  dynamic "rule" {
  # Iterate over each rule defined in the `rules` variable
    for_each = var.rules
     # Content block for each rule
    content {
      # Action to take when the rule matches (e.g., "allow" or "deny")
      action   = rule.value.action
      # Priority of the rule (lower numbers have higher precedence)
      priority = rule.value.priority
      # Match condition for the rule
      match {
        # Use the SRC_IPS_V1 expression to match source IP ranges
        versioned_expr = "SRC_IPS_V1"
        # Configuration for the match condition
        config {
          # List of source IP ranges to match against
          src_ip_ranges = rule.value.src_ip_ranges
        }
      }
      description = rule.value.description
    }
  }
}

*/
