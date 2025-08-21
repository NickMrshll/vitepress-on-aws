locals {
  fqdn = var.vitepress_subdomain == "@" ? var.domain_name : "${var.vitepress_subdomain}.${var.domain_name}"
}

# Get the existing hosted zone
data "aws_route53_zone" "primary_zone" {
  name         = "${var.domain_name}."
  private_zone = false
}

# Route 53 record for CloudFront
resource "aws_route53_record" "cdn" {
  zone_id = data.aws_route53_zone.primary_zone.zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.vitepress_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.vitepress_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
