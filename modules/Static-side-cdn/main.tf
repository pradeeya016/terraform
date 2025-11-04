# A unique identifier for the CloudFront origin
locals {
  s3_origin_id = "S3-Origin-${var.bucket_name}"
}

#S3 Bucket Resources

resource "aws_s3_bucket" "checkpoint_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags          = var.tags
}

#CloudFront Origin Access Control (OAC)

resource "aws_cloudfront_origin_access_control" "checkpoint_oac" {
  name                              = "oac-${var.bucket_name}"
  description                       = "OAC for S3 bucket ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#IAM Policy Document for CloudFront/S3 Integration

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# S3 Bucket Policy that allows CloudFront OAC access
resource "aws_s3_bucket_policy" "checkpoint_s3_bucket_policy" {
  bucket = aws_s3_bucket.checkpoint_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.checkpoint_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.checkpoint_s3_distribution.arn
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket.checkpoint_bucket,
    aws_cloudfront_distribution.checkpoint_s3_distribution
  ]
}

#CloudFront Distribution
resource "aws_cloudfront_distribution" "checkpoint_s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.checkpoint_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.checkpoint_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled         = true
  is_ipv6_enabled = true
  
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    # Use forwarded_values instead of cache_policy_id for compatibility
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

  tags = var.tags
}
