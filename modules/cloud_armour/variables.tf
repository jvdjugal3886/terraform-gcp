# Variable block for defining the name of the Cloud Armor security policy
variable "security_policy_name" {
  description = "Name of the Cloud Armor security policy"
  type        = string
}

# Variable block for defining the list of security rules for Cloud Armor
variable "rules" {
  description = "List of security rules for Cloud Armor"
  type = list(object({

    # Priority of the rule (lower numbers have higher precedence)
    priority = number

    # Action to take when the rule matches (e.g., "allow" or "deny")
    action = string

    # List of source IP ranges to match against
    src_ip_ranges = list(string)
    description   = string
  }))
}
