output "cloudfront_url" {
  value = aws_cloudfront_distribution.vitepress_cdn.domain_name
}
