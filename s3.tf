# S3 bucket for VitePress build
resource "aws_s3_bucket" "vitepress_site" {
  bucket_prefix = var.bucket_prefix
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.vitepress_site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Prevent public access
resource "aws_s3_bucket_public_access_block" "vitepress_site" {
  bucket = aws_s3_bucket.vitepress_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy to allow CloudFront access
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
