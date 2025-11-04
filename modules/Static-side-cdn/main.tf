# A unique identifier for the CloudFront origin
locals {
  s3_origin_id = "S3-Origin-${var.bucket_name}"
}

#S3 Bucket Resources

resource "aws_s3_bucket" "checkpoint_bucket" {
  bucket = var.bucket_name
  tags   = var.tags
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

# This policy allows CloudFront to read objects from S3 ONLY if the request comes from OAC cloudfront.
data "aws_iam_policy_document" "policy_for_s3_bucket" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.checkpoint_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      # The distribution ID is known only after the distribution is created.
      # This dependency forces CloudFront to create the ARN correctly.
      values   = [aws_cloudfront_distribution.checkpoint_s3_distribution.arn]
    }
  }
}

#S3 Bucket Policy Attachment

resource "aws_s3_bucket_policy" "checkpoint_s3_bucket_policy" {
  bucket = aws_s3_bucket.checkpoint_bucket.id
  policy = data.aws_iam_policy_document.policy_for_s3_bucket.json

  # Dependency to ensure the OAC and Bucket are ready before applying the policy
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

    # Using managed cache policy - cannot use forwarded_values with cache_policy_id
    cache_policy_id = "658327ea-f89d-4c51-8b74-4b534e819b58" # Managed-CachingOptimized
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
}
