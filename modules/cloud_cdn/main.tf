# Create Google Storage Buckets with enhanced configurations
resource "google_storage_bucket" "cdn_bucket" {
  for_each                    = { for idx, instance in var.cdn_instances : idx => instance }
  name                        = "${each.value.bucket_name}-${var.env}" # Append env to bucket name
  location                    = each.value.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true

  # Versioning - enables keeping multiple versions of objects for backup and recovery
  versioning {
    enabled = each.value.versioning_enabled
  }

  # Lifecycle Management - automatically manages object lifecycle based on defined rules
  dynamic "lifecycle_rule" {
    for_each = each.value.lifecycle_rules
    content {
      action {
        type = lifecycle_rule.value.action_type
      }
      condition {
        age = lifecycle_rule.value.age_days
      }
    }
  }

  # CORS Configuration - controls how the bucket responds to cross-origin requests
  dynamic "cors" {
    for_each = each.value.cors
    content {
      origin          = cors.value.origins
      method          = cors.value.methods
      response_header = cors.value.response_headers
      max_age_seconds = cors.value.max_age_seconds
    }
  }
}

# Create Google Compute Backend Buckets with Cache Control
resource "google_compute_backend_bucket" "cdn_backend" {
  for_each    = { for idx, instance in var.cdn_instances : idx => instance }
  name        = "cdn-backend-${each.value.name}-${var.env}" # Append env to backend bucket name
  bucket_name = google_storage_bucket.cdn_bucket[each.key].name
  enable_cdn  = true

  # Configure CDN caching behavior
  cdn_policy {
    cache_mode  = each.value.cache_policy.cache_mode
    default_ttl = each.value.cache_policy.default_ttl
    max_ttl     = each.value.cache_policy.max_ttl
  }
}

# URL Map - defines how requests are routed to backend services
resource "google_compute_url_map" "cdn_url_map" {
  for_each        = { for idx, instance in var.cdn_instances : idx => instance }
  name            = "cdn-url-map-${each.value.name}-${var.env}" # Append env to URL map name
  default_service = google_compute_backend_bucket.cdn_backend[each.key].id
}

# HTTP Forwarding Rule - since we removed HTTPS, we'll use HTTP instead
resource "google_compute_global_forwarding_rule" "cdn_http_forwarding_rule" {
  for_each   = { for idx, instance in var.cdn_instances : idx => instance }
  name       = "cdn-http-forwarding-rule-${each.value.name}-${var.env}" # Append env to forwarding rule name
  target     = google_compute_target_http_proxy.cdn_http_proxy[each.key].id
  port_range = "80" # Changed from 443 to 80 for HTTP
}

# HTTP Proxy - replaced HTTPS proxy with HTTP proxy
resource "google_compute_target_http_proxy" "cdn_http_proxy" {
  for_each = { for idx, instance in var.cdn_instances : idx => instance }
  name     = "cdn-http-proxy-${each.value.name}-${var.env}" # Append env to HTTP proxy name
  url_map  = google_compute_url_map.cdn_url_map[each.key].id
}



