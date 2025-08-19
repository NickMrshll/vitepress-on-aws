# Origin Access Control for S3
resource "aws_cloudfront_origin_access_control" "vitepress" {
  name                              = "vitepress-oac"
  description                       = "OAC for VitePress site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "vitepress_cdn" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.vitepress_site.bucket_regional_domain_name
    origin_id                = "vitepress-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.vitepress.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "vitepress-s3"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 0
  }
}

# Invalidate CloudFront cache after updates
resource "null_resource" "cloudfront_invalidation" {
  depends_on = [
    aws_s3_object.vitepress_files,
    aws_cloudfront_distribution.vitepress_cdn
  ]

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.vitepress_cdn.id} --paths '/*'"
  }

  triggers = {
    source_hash = sha256(join("", [
      for f in fileset("${path.module}/docs/.vitepress/dist", "**") : filesha256("${path.module}/docs/.vitepress/dist/${f}")
    ]))
  }
}
