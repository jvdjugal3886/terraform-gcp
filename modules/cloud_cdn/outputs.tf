output "bucket_urls" {
  value       = { for idx, bucket in google_storage_bucket.cdn_bucket : idx => bucket.url }
  description = "URLs of the created Cloud Storage buckets used for serving content via the CDN"
}

output "http_proxy_urls" {
  value       = { for idx, proxy in google_compute_target_http_proxy.cdn_http_proxy : idx => proxy.self_link }
  description = "URLs of the created HTTP proxies that handle content delivery"
}


output "forwarding_rule_ips" {
  value       = { for idx, rule in google_compute_global_forwarding_rule.cdn_http_forwarding_rule : idx => rule.ip_address }
  description = "IP addresses assigned to global forwarding rules for routing traffic"
}
