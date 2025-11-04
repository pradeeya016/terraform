# --- CloudFront S3 Module (outputs.tf) ---

output "bucket_id" {
  description = "The name (id) of the S3 bucket."
  value       = aws_s3_bucket.checkpoint_bucket.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.checkpoint_s3_distribution.domain_name
}

output "cloudfront_arn" {
  description = "The ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.checkpoint_s3_distribution.arn
}