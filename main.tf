# S3 static website bucket


resource "aws_s3_bucket" "my-static-website" {
  bucket = "${var.bucket_name}-${var.bucket_env}" # give a unique bucket name
  force_destroy = true
  tags = {
    Name = "By ${var.bucket_name}"
    Environment = var.bucket_env
  }
}

resource "aws_s3_bucket_website_configuration" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket ACL access

resource "aws_s3_bucket_ownership_controls" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "my-static-website" {
  bucket = aws_s3_bucket.my-static-website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "my-static-website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.my-static-website,
    aws_s3_bucket_public_access_block.my-static-website,
  ]

  bucket = aws_s3_bucket.my-static-website.id
  acl    = "public-read"
}




# s3 static website url

output "website_url" {
  value = "http://${aws_s3_bucket.my-static-website.bucket}.s3-website.us-east-1.amazonaws.com"
}

# S3 static website bucket
resource "aws_s3_bucket" "my-static-website" {
  # ... (Your existing S3 bucket configuration)
}

# ... (Your existing S3 bucket website configuration, versioning, ACLs, outputs, etc.)

# CloudFront distribution for the S3 static website
resource "aws_cloudfront_distribution" "my-cloudfront-distribution" {
  origin {
    domain_name = aws_s3_bucket.my-static-website.bucket_regional_domain_name
    origin_id   = "S3-origin"
  }

  enabled = true

  default_cache_behavior {
    target_origin_id = "S3-origin"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Set other caching configurations as needed
    # ...

    # Set TTLs as needed
    # ...
  }

  # Add more cache behaviors, restrictions, SSL settings, etc., as needed

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Add tags for the CloudFront distribution if needed
  tags = {
    Name        = "MyCloudFrontDistribution"
    Environment = "Dev"
    # Add more tags if needed
  }
}
