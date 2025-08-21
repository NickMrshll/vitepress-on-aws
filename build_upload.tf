# Build VitePress locally
resource "null_resource" "vitepress_build" {
  provisioner "local-exec" {
    command     = "npm install && npm run docs:build"
    working_dir = path.module
  }

  triggers = {
    source_hash = sha256(join("", [
      for f in fileset("${path.module}/docs/.vitepress/dist", "**/*") : filesha256("${path.module}/docs/.vitepress/dist/${f}")
    ]))
  }
}

# Upload build files to S3
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
