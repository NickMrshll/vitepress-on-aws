terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# --- S3 bucket for VitePress build ---
resource "aws_s3_bucket" "vitepress_site" {
  bucket_prefix = var.bucket_prefix # must be globally unique
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.vitepress_site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block ALL public access (bucket private)
resource "aws_s3_bucket_public_access_block" "vitepress_site" {
  bucket = aws_s3_bucket.vitepress_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- Build VitePress locally before upload ---
resource "null_resource" "vitepress_build" {
  provisioner "local-exec" {
    command     = "npm install && npm run docs:build" # or vitepress build
    working_dir = path.module
  }

  triggers = {
    source_hash = sha256(join("", [for f in fileset("${path.module}/docs/.vitepress/dist", "**") : filesha256("${path.module}/docs/.vitepress/dist/${f}")]))
  }
}

# --- Upload VitePress build output to S3 ---
resource "aws_s3_object" "vitepress_files" {
  for_each = fileset("${path.module}/docs/.vitepress/dist", "**/*")

  bucket = aws_s3_bucket.vitepress_site.bucket
  key    = each.value
  source = "${path.module}/docs/.vitepress/dist/${each.value}"
  etag   = filemd5("${path.module}/docs/.vitepress/dist/${each.value}")

  content_type = lookup(
    {
      html = "text/html"
      css  = "text/css"
      js   = "application/javascript"
      json = "application/json"
      png  = "image/png"
      jpg  = "image/jpeg"
      jpeg = "image/jpeg"
      gif  = "image/gif"
      svg  = "image/svg+xml"
    },
    regex("^.*\\.([^.]+)$", each.value)[0],
    "application/octet-stream"
  )

  depends_on = [null_resource.vitepress_build]
}

# --- CloudFront Origin Access Control (OAC) ---
resource "aws_cloudfront_origin_access_control" "vitepress" {
  name                              = "vitepress-oac"
  description                       = "OAC for VitePress site"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# --- CloudFront Distribution ---
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

  price_class = "PriceClass_100" # cheapest (US, Canada, Europe)

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

resource "null_resource" "cloudfront_invalidation" {
  depends_on = [
    aws_s3_object.vitepress_files,
    aws_cloudfront_distribution.vitepress_cdn
  ]

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.vitepress_cdn.id} --paths '/*'"
  }

  triggers = {
    source_hash = sha256(join("", [for f in fileset("${path.module}/docs/.vitepress/dist", "**") : filesha256("${path.module}/docs/.vitepress/dist/${f}")]))
  }
}


# --- S3 bucket policy to allow CloudFront to fetch objects ---
data "aws_iam_policy_document" "s3_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.vitepress_site.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.vitepress_cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "vitepress_policy" {
  bucket = aws_s3_bucket.vitepress_site.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

# --- Outputs ---
output "cloudfront_url" {
  value = aws_cloudfront_distribution.vitepress_cdn.domain_name
}

