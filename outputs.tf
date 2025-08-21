output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.vitepress_cdn.domain_name}"
}

output "vanity_url" {
  value = "https://${local.fqdn}"
}
