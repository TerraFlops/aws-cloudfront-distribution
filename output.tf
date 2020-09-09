output "distribution_id" {
  description = "The AWS resource ID of the CloudFront distribution"
  value = aws_cloudfront_distribution.distribution.id
}

output "distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value = aws_cloudfront_distribution.distribution.domain_name
}

output "distribution_zone_id" {
  description = "The domain name of the CloudFront distribution"
  value = aws_cloudfront_distribution.distribution.hosted_zone_id
}

output "log_bucket_arn" {
  description = "The ARN of the newly created log bucket"
  value = var.log_bucket_create == true ? aws_s3_bucket.logs[0].arn : null
}
